# frozen_string_literal: true

# This file contains setup for environment variables using Dotenv.

Application.register_provider(:environment_variables) do
  start do
    # Get Application current environment.
    env = Application.env

    # Load environment variables
    require 'dotenv'

    Dotenv.load('.env', ".env.#{env}")
  end
end
