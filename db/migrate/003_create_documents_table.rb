# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:documents) do
      column :id,          :uuid, null: false, default: Sequel.function(:uuid_generate_v4), primary_key: true
      column :name,        String, null: false
      column :path,        String, null: false
      column :size,        Integer, null: false
      column :created_at,  DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :started_at,  DateTime
      column :finished_at, DateTime
    end
  end
end
