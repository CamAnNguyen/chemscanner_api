# frozen_string_literal: true

# {MoleculeExpander} replace rgroup with superatom
class MoleculeExpander
  # Constructor
  def initialize(rw_mol:, rgroup:, smiles:)
    @rw_mol = rw_mol
    @rgroup = rgroup
    @smiles = smiles
  end

  # Generates molecules from rgroups
  def call
    deleting_atom = []

    (0..(@rw_mol.get_num_atoms - 1)).each do |idx|
      atom = @rw_mol.get_atom_with_idx(idx)
      next unless atom.get_symbol == @rgroup

      deleting_atom.push(atom)
      expand(atom)
    end

    deleting_atom.each do |atom|
      @rw_mol.remove_atom(atom)
    end
  end

  # Expand/replace rgroup atom by smiles
  def expand(atom)
    ref = RDKitChem::RWMol.new(@rw_mol)

    atom_idx = atom.get_idx
    first_expand_idx = @rw_mol.get_num_atoms

    expand_mol = RDKitChem::RWMol.mol_from_smiles(@smiles)
    @rw_mol.insert_mol(expand_mol)

    bonds = get_atom_bonds(atom_idx)
    bonds.each do |bond|
      other_idx = bond.get_other_atom_idx(atom_idx)
      @rw_mol.remove_bond(other_idx, atom_idx)
      @rw_mol.add_bond(other_idx, first_expand_idx, bond.get_bond_type)
    end

    # Generate added atom coords
    begin
      @rw_mol.compute_2dcoords(ref)
    rescue RuntimeError
      nil
    end
  end

  # Get list bonds that connect to specified atom
  def get_atom_bonds(atom_idx)
    bonds = []
    (0..(@rw_mol.get_num_bonds - 1)).each do |idx|
      bond = @rw_mol.get_bond_with_idx(idx)
      bond_atom_ids = [bond.get_begin_atom_idx, bond.get_end_atom_idx]
      bonds.push(bond) if bond_atom_ids.include?(atom_idx)
    end

    bonds
  end

  # Return RDKitChem::RWMol from mdl
  def rdkit_mol_from_mdl(mdl)
    RDKitChem::RWMol.mol_from_mol_block(mdl)
  rescue RuntimeError
    RDKitChem::RWMol.mol_from_mol_block(mdl, false)
  end
end
