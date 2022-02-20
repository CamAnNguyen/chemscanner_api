# frozen_string_literal: true

module Tasks
  # {Task::Creator} creates {Task}
  class Creator
    # @param [Hash] attributes of the {File}
    def initialize(doc)
      @doc = doc
    end

    # Creates {File} based on the passed attributes.
    def call
      Task.create(
        document_id: @doc.id,
        created_at: Time.now
      )
    end
  end
end
