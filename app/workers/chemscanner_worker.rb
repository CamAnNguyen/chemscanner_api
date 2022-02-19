# frozen_string_literal: true

# Chemscanner woker
class ChemscannerWorker
  include Sidekiq::Worker

  # perform scanning
  def perform(_id)
    puts('worker in progress')
  end
end
