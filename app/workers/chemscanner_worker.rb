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
      molecules: cs_output&.molecules || [],
      reactions: cs_output&.reactions || []
    )

    logger.info("Posting job #{task.job_id} result to #{task.postback_url}")
    post_output(output.render, task.job_id, task.postback_url)
    finish_task(task, output.to_json)
  end

  private

  def start_task(task)
    logger.info("Starting task #{task.id} - job #{jid}")
    task.update(started_at: Time.now, job_id: jid)
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

  def post_output(output, job_id, postback_url)
    return if postback_url.nil?

    response = HTTParty.post(
      postback_url,
      headers: { 'Content-Type' => 'application/json' },
      body: { job_id: job_id, data: output }
    )

    if response.success?
      logger.info("Posting output to #{postback_url} succeeded: #{response}")
    else
      logger.error("Error posting output #{job_id} to #{postback_url}: #{response}")
    end
  rescue StandardError => e
    logger.error("Error posting output to: #{postback_url} - #{e.message}")
  end
end
