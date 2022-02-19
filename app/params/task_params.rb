# frozen_string_literal: true

# @example When params are valid:
#   TaskParams.new.permit!(name: 'file.cdx')
#
# @example When params are invalid:
#   TaskParams.new.permit!({})
class TaskParams < ApplicationParams
  params do
    required(:name).filled(:string)
  end
end
