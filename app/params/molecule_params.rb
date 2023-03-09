# frozen_string_literal: true

# {RgroupParams} validates POST /api/v1/rgroup params.
class MoleculeParams < ApplicationParams
  params do
    required(:mdl).filled(:string)
  end
end
