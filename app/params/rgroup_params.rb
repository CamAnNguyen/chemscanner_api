# frozen_string_literal: true

# {RgroupParams} validates POST /api/v1/rgroup params.
class RgroupParams < ApplicationParams
  params do
    required(:mdl).filled(:string)
    required(:rgroups).array(:hash)
  end
end
