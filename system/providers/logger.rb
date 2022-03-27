# frozen_string_literal: true

# This file contains logger configuration.

Application.register_provider(:logger) do
  prepare do
    require 'logger'
  end

  start do
    # Define Logger instance.
    logger =
      if Application.env == 'production'
        Logger.new('log/production.log')
      else
        Logger.new($stdout)
      end

    # Because the Logger's level is set to WARN , only the warning, error, and fatal messages are recorded.
    logger.level = Logger::WARN if Application.env == 'test'
    logger.level = Logger::DEBUG if Application.env == 'development'

    # Register logger component.
    register(:logger, logger)
  end
end
