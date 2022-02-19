# frozen_string_literal: true

# ping route
class App
  hash_routes('/api/v1').on('ping') do |r|
    r.get do
      { success: true }.to_json
    end
  end
end
