# frozen_string_literal: true

# This file contain code to setup the redis connection.

Application.register_provider(:redis) do
  prepare do
    require 'redis'
  end

  start do
    # Load environment variables before setting up redis connection.
    target.start(:environment_variables)

    # Define Redis instance.
    redis = Redis.new(url: ENV['REDIS_URL'])

    # Register redis component.
    register(:redis, redis)
  end
end
