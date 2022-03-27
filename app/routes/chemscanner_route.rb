# frozen_string_literal: true

# Chemscanner route
class App
  POSTBACK_PARAM = 'postback_url'
  public_constant :POSTBACK_PARAM

  storage_path = ENV['STORAGE'].end_with?('/') ? ENV['STORAGE'] : "#{ENV['STORAGE']}/"

  hash_routes('/api/v1').on('chemscanner') do |r|
    r.on('scan') do
      r.post do
        files = []
        postback_url = r.params[POSTBACK_PARAM]

        r.params.reject { |k| k == POSTBACK_PARAM }.each do |filename, file|
          tmp_file = file[:tempfile]
          tmp_path = tmp_file&.path
          next if tmp_path.nil?

          file_path = storage_path + File.basename(tmp_path)
          FileUtils.cp(tmp_path, file_path)
          next unless File.file?(file_path)

          file_attributes =
            {
              name: filename,
              path: file_path,
              size: tmp_file.size
            }
          file = Documents::Creator.new(attributes: file_attributes).call
          task = Tasks::Creator.new(doc: file, postback_url: postback_url).call
          jid = ChemscannerWorker.perform_async(file.id, task.id)
          next if jid.nil?

          files.push({ file: filename, job_id: jid })
        end

        { files: files }.to_json
      end
    end
  end
end
