# frozen_string_literal: true

# {RgroupGenerator} generates molecules from rgroup information
class RgroupGenerator
  BOND_TYPE_HYDROGEN = 14
  public_constant :BOND_TYPE_HYDROGEN

  BOND_TYPE_OTHER = 20
  public_constant :BOND_TYPE_OTHER

  # Constructor
  def initialize(mdl:, rgroup_data:)
    @mdl = mdl
    @rgroup_data = rgroup_data
  end

  # Generates molecules from rgroups
  def call
    molecules = []

    (@rgroup_data || []).each do |data|
      rw_mol = rdkit_mol_from_mdl(@mdl)
      next if rw_mol.nil?

      data.each do |rgroup, superatom|
        MoleculeExpander.new(rw_mol: rw_mol, rgroup: rgroup, superatom: superatom).call
      end

      mdl = rw_mol.mol_to_mol_block(true, -1, false, true)
      inchi = try_get_inchi(mdl)

      molecule = data.merge(
        mdl: mdl,
        smiles: rw_mol.mol_to_smiles(true),
        inchi: inchi,
        inchikey: Inchi.InchiToInchiKey(inchi)
      )
      molecules.push(molecule)
    end

    molecules
  end

  # Return RDKitChem::RWMol from mdl
  def rdkit_mol_from_mdl(mdl)
    RDKitChem::RWMol.mol_from_mol_block(mdl)
  rescue RuntimeError
    RDKitChem::RWMol.mol_from_mol_block(mdl, false)
  end

  # Try to get inchi from mdl
  def try_get_inchi(mdl)
    inchi = Inchi.molfileToInchi(mdl, Inchi::ExtraInchiReturnValues.new, '-Polymers')
    return inchi unless inchi.empty?

    mol = rdkit_mol_from_mdl(mdl)
    bonds_to_remove = get_zero_order_bonds(mol)

    bonds_to_remove.each do |bond|
      mol.remove_bond(bond[0], bond[1])
    end

    new_mdl = mol.mol_to_mol_block(true, -1, true, true)
    Inchi.molfileToInchi(new_mdl, Inchi::ExtraInchiReturnValues.new, '-Polymers')
  end

  # Get zero-order bonds
  def get_zero_order_bonds(mol)
    zero_order_bonds = []
    (0..(mol.get_num_bonds - 1)).map do |idx|
      bond = mol.get_bond_with_idx(idx)

      case bond.get_bond_type
      when BOND_TYPE_HYDROGEN
        zero_order_bonds.push([bond.get_begin_atom_idx, bond.get_end_atom_idx])
      when BOND_TYPE_OTHER
        bond.set_bond_type(1)
      end
    end

    zero_order_bonds
  end
end
