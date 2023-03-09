# frozen_string_literal: true

# {RgroupGenerator} generates molecules from rgroup information
class MoleculeInfo
  BOND_TYPE_HYDROGEN = 14
  public_constant :BOND_TYPE_HYDROGEN

  BOND_TYPE_OTHER = 20
  public_constant :BOND_TYPE_OTHER

  # Constructor
  def initialize(mdl:)
    @mdl = mdl
  end

  # Generates molecules from rgroups
  def call
    rw_mol = rdkit_mol_from_mdl(@mdl)

    begin
      RDKitChem.kekulize(rw_mol)
      RDKitChem.sanitize_mol(rw_mol)
    rescue StandardError
    end

    get_mol_data(rw_mol)
  end

  # get other molecule format
  def get_mol_data(rw_mol)
    mdl = rw_mol.mol_to_mol_block(true, -1, false, true)
    simplified_mol = simplify_mol(mdl)
    inchi = try_get_inchi(mdl, simplified_mol)
    ro_mol = RDKitChem::RWMol.to_romol(rw_mol)

    {
      mdl: @mdl,
      smiles: try_get_smiles(rw_mol, simplified_mol),
      inchi: inchi,
      inchikey: Inchi.InchiToInchiKey(inchi),
      molecular_weight: try_get_molecular_weight(ro_mol),
      formula: try_get_molecule_formula(ro_mol)
    }.compact
  end

  # get molecular weight, return nil if any exception occurs
  def try_get_molecular_weight(ro_mol)
    RDKitChem.calc_exact_mw(ro_mol)
  rescue StandardError
    nil
  end

  # get molecule formula, return nil if any exception occurs
  def try_get_molecule_formula(ro_mol)
    RDKitChem.calc_mol_formula(ro_mol)
  rescue StandardError
    nil
  end

  # Return RDKitChem::RWMol from mdl
  def rdkit_mol_from_mdl(mdl)
    RDKitChem::RWMol.mol_from_mol_block(mdl)
  rescue StandardError
    RDKitChem::RWMol.mol_from_mol_block(mdl, false)
  end

  # Simplify molecule, convert bond type 10 to hydrogen, 8 to other type
  def simplify_mol(mdl)
    mol = rdkit_mol_from_mdl(mdl)
    bonds_to_remove = get_zero_order_bonds(mol)

    bonds_to_remove.each do |bond|
      mol.remove_bond(bond[0], bond[1])
    end

    mol
  end

  # Try to get inchi from mdl
  def try_get_inchi(mdl, mol)
    inchi = Inchi.molfileToInchi(mdl, Inchi::ExtraInchiReturnValues.new, '-Polymers')
    return inchi unless inchi.empty?

    new_mdl = mol.mol_to_mol_block(true, -1, true, true)
    Inchi.molfileToInchi(new_mdl, Inchi::ExtraInchiReturnValues.new, '-Polymers')
  end

  # get molecule SMILES, return nil if any exception occurs
  def try_get_smiles(mol, simplified_mol)
    mol.mol_to_smiles(true)
  rescue RuntimeError
    simplified_mol.mol_to_smiles(true)
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
