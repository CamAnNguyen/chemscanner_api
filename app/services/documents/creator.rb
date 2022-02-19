# frozen_string_literal: true

module Documents
  # {File::Creator} creates {File}
  class Creator
    # @param [Hash] attributes of the {File}
    def initialize(attributes:)
      @attributes = attributes
    end

    # Creates {File} based on the passed attributes.
    def call
      Document.create(
        name: @attributes[:name],
        path: @attributes[:path],
        size: @attributes[:size]
      )
    end
  end
end
