# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :tasks, :postback_url, String
  end
end
