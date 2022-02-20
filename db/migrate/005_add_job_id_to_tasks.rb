# frozen_string_literal: true

Sequel.migration do
  change do
    add_column :tasks, :job_id, String, unique: true
    add_index :tasks, :job_id, unique: true
  end
end
