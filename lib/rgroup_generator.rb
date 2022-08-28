# frozen_string_literal: true

require 'debug'

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
        smiles = ChemScanner.get_superatom(superatom)
        next if smiles.empty?

        MoleculeExpander.new(rw_mol: rw_mol, rgroup: rgroup, smiles: smiles).call
      end

      mdl = rw_mol.mol_to_mol_block(true, -1, false)
      molecules.push(data.merge(mdl: mdl))
    end

    molecules
  end

  # Return RDKitChem::RWMol from mdl
  def rdkit_mol_from_mdl(mdl)
    RDKitChem::RWMol.mol_from_mol_block(mdl)
  rescue RuntimeError
    RDKitChem::RWMol.mol_from_mol_block(mdl, false)
  end
end
