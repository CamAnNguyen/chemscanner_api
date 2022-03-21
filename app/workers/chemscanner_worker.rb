# frozen_string_literal: true

require 'httparty'

# Chemscanner woker
class ChemscannerWorker
  include Sidekiq::Worker

  # perform scanning
  def perform(doc_id, task_id)
    task = Task.with_pk!(task_id)
    start_task(task)
    cs_output = scan_document(doc_id)
    output = ChemscannerSerializer.new(
      molecules: cs_output.molecules,
      reactions: cs_output.reactions
    )
    post_output(output.render, task.job_id)
    finish_task(task, output.to_json)
  end

  private

  def start_task(task)
    task.update(started_at: Time.now)
  end

  def finish_task(task, output)
    task.update(started_at: Time.now)
    task.update(finished_at: Time.now, output: output)
    logger.info("Finished task #{task.id}: #{output}")
  end

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
  rescue StandardError => e
    logger.error("Error posting output to: #{ENV['POSTBACK_URL']} - #{e.message}")
  end
end
