# frozen_string_literal: true

Sequel.migration do
  change do
    create_table(:tasks) do
      column :id,          :uuid, null: false, default: Sequel.function(:uuid_generate_v4), primary_key: true
      column :output,      :jsonb
      column :created_at,  DateTime, null: false, default: Sequel::CURRENT_TIMESTAMP
      column :started_at,  DateTime
      column :finished_at, DateTime

      foreign_key :document_id, :documents, type: 'uuid', null: false, on_delete: :cascade
    end
  end
end
