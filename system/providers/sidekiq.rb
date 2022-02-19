# frozen_string_literal: true

# This file contain configuration for Sidekiq.

Application.register_provider(:sidekiq) do
  prepare do
    require 'sidekiq'
    require 'sidekiq/web'
  end

  start do
    # Load environment variables before setting up redis connection.
    target.start(:environment_variables)

    # Configuration for Sidekiq server.
    Sidekiq.configure_server do |config|
      config.redis = { url: ENV['REDIS_URL'] }
    end

    # Configuration for Sidekiq client.
    Sidekiq.configure_client do |config|
      config.redis = { url: ENV['REDIS_URL'] }
    end
  end
end
