# frozen_string_literal: true

# {RgroupGenerator} generates molecules from rgroup information
class RgroupGenerator
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

      begin
        RDKitChem.kekulize(rw_mol)
        RDKitChem.sanitize_mol(rw_mol)
      rescue StandardError
      end

      rw_mol_mdl = rw_mol.mol_to_mol_block(true, -1, false, true)
      mol_data = MoleculeInfo.new(mdl: rw_mol_mdl).call
      molecule = data.merge(mol_data)
      molecules.push(molecule)
    end

    molecules
  end

  # Return RDKitChem::RWMol from mdl
  def rdkit_mol_from_mdl(mdl)
    RDKitChem::RWMol.mol_from_mol_block(mdl)
  rescue StandardError
    RDKitChem::RWMol.mol_from_mol_block(mdl, false)
  end
end
