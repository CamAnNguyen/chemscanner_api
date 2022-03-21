# frozen_string_literal: true

require 'bundler/setup'
require 'dry/system/container'

# {Application} is a container that we use it to register dependencies we need to call.
class Application < Dry::System::Container
  # Provide environment inferrerr.
  use :env, inferrer: -> { ENV.fetch('RACK_ENV', 'development') }
  use :zeitwerk

  configure do |config|
    # config.component_dirs.add('.')
    config.autoloader.collapse('.')

    folders = (Dir.glob('app/*') + ['./lib']).reject { |f| f == 'app/routes' }
    folders.each { |folder| config.component_dirs.add(folder) }

    config.autoloader.enable_reloading if env == 'development'
  end
end
