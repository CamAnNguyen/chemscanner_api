# frozen_string_literal: true

require 'httparty'

# Chemscanner woker
class ChemscannerWorker
  include Sidekiq::Worker

  # perform scanning
  def perform(doc_id, task_id)
    task = Task.with_pk!(task_id)
    task.update(started_at: Time.now)

    cs_output = scan_document(doc_id)
    output = ChemscannerSerializer.new(
      molecules: cs_output.molecules,
      reactions: cs_output.reactions
    )
    post_output(output.render, task.job_id)

    task.update(finished_at: Time.now, output: output)
  end

  private

  def scan_document(doc_id)
    doc = Document.with_pk!(doc_id)
    filename = doc.name
    file_ext = File.extname(filename).downcase

    func_name = "#{file_ext[1..]}_process".to_sym
    return unless Chemscanner::Process.respond_to?(func_name)

    Chemscanner::Process.public_send(func_name, doc)
  end

  def post_output(output, job_id)
    return if ENV['POSTBACK_URL'].nil?

    HTTParty.post(
      "#{ENV['POSTBACK_URL']}/jobs/#{job_id}/notify-done",
      headers: { 'Content-Type' => '*' },
      body: { data: output }
    )
  end
end
