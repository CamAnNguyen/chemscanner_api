# frozen_string_literal: true

# File model
class Document < Sequel::Model
  one_to_one :task

  dataset_module do
    # Filters files by their name.
    def search_by_name(name)
      where(Sequel.ilike(:name, "%#{name}%"))
    end
  end
end
