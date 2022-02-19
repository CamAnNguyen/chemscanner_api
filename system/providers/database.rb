# frozen_string_literal: true

# This file contain code to setup the database connection.

Application.register_provider(:database) do
  prepare do
    require 'sequel/core'
  end

  start do
    # Load environment variables before setting up redis connection.
    target.start(:environment_variables)

    # Delete DATABASE_URL from the environment, so it isn't accidently passed to subprocesses.
    database = Sequel.connect(ENV.delete('DATABASE_URL'))

    # Register database component.
    register(:database, database)
  end
end
