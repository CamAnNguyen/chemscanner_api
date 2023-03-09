# frozen_string_literal: true

# Rgroup route
class App
  hash_routes('/api/v1').on('molecules') do |r|
    r.post do
      molecule_params = MoleculeParams.new.permit!(r.params)
      data = MoleculeInfo.new(mdl: molecule_params[:mdl]).call

      RgroupSerializer.new(data: data).render
    end
  end
end
