# frozen_string_literal: true

# Final serializer of ChemScanner output
class RgroupSerializer < ApplicationSerializer
  # ChemScanner output to json
  def to_json
    @data
  end
end
