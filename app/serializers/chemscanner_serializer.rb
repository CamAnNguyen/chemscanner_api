# frozen_string_literal: true

# Final serializer of ChemScanner output
class ChemscannerSerializer < ApplicationSerializer
  # ChemScanner output to json
  def to_json
    {
      molecules: molecules,
      reactions: reactions
    }
  end

  private

  def molecules
    @molecules.map do |m|
      {
        id: m.id,
        cano_smiles: m.cano_smiles,
        mdl: m.mdl,
        label: m.label,
        text: m.text
      }
    end
  end

  # {:id=>1115,
  #  :reactants=>[{:id=>1004, :smiles=>"N#CC1=CNN=C1N", :label=>"16", :text=>""}],
  #  :reagents=>[],
  #  :products=>[{:id=>1059, :smiles=>"CC(C)N(/N=N/C1=NNC=C1C#N)C(C)C", :label=>"15", :text=>"(45%)"}],
  #  :steps=>
  #   [{:number=>1, :description=>"NaNO2, HCl, H2O, 0-5 °C\n", :time=>"", :temperature=>"0-5 °C", :reagents=>["[O-]N=O.[Na+]", "Cl", "O"]},
  #    {:number=>2, :description=>"Diisopropylamine, K2CO3", :time=>"", :temperature=>"", :reagents=>["[O-]C(=O)[O-].[K+].[K+]"]}],
  #  :reagent_smiles=>["Cl", "O", "[O-]C(=O)[O-].[K+].[K+]", "[O-]N=O.[Na+]"],
  #  :description=>"1) NaNO2, HCl, H2O, 0-5 °C\n2) Diisopropylamine, K2CO3",
  #  :temperature=>"0-5 °C",
  #  :yield=>"45%",
  #  :time=>"",
  #  :details=>{}}
  def reactions
    @reactions.map(&:to_hash)
  end
end
