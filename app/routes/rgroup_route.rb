# frozen_string_literal: true

# Rgroup route
class App
  hash_routes('/api/v1').on('rgroup') do |r|
    r.post do
      rgroup_params = RgroupParams.new.permit!(r.params)
      data = RgroupGenerator.new(
        mdl: rgroup_params[:mdl],
        rgroup_data: rgroup_params[:rgroups]
      ).call

      RgroupSerializer.new(data: data).render
    end
  end
end
