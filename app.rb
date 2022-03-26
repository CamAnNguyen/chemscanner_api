# frozen_string_literal: true

require 'roda'

require_relative './system/boot'

# The main class for Roda Application.
class App < Roda
  # Adds support for handling different execution environments (development/test/production).
  plugin :environments

  # Adds support for heartbeats.
  plugin :heartbeat

  configure :development, :production do
    # A powerful logger for Roda with a few tricks up it's sleeve.
    plugin :enhanced_logger
  end

  # The symbol_matchers plugin allows you do define custom regexps to use for specific symbols.
  plugin :symbol_matchers

  # Validate UUID format.
  symbol_matcher :uuid, Constants::UUID_REGEX

  # Adds ability to automatically handle errors raised by the application.
  plugin :error_handler do |e|
    Application[:logger].error(e)

    if e.instance_of?(Exceptions::InvalidParamsError)
      error_object    = e.object
      response.status = 422
    elsif e.instance_of?(Sequel::ValidationFailed)
      error_object    = e.model.errors
      response.status = 422
    elsif e.instance_of?(Exceptions::InvalidEmailOrPassword)
      error_object    = { error: 'invalid_email_or_password' }
      response.status = 401
    elsif e.instance_of?(ActiveSupport::MessageVerifier::InvalidSignature)
      error_object    = { error: 'invalid_authorization_token' }
      response.status = 401
    elsif e.instance_of?(Sequel::NoMatchingRow)
      error_object    = { error: 'not_found' }
      response.status = 404
    else
      error_object    = { error: 'something_went_wrong' }
      response.status = 500
    end

    response.write(error_object.to_json)
  end

  # Allows modifying the default headers for responses.
  plugin :default_headers,
         'Content-Type' => 'application/json',
         'Strict-Transport-Security' => 'max-age=16070400;',
         'X-Frame-Options' => 'deny',
         'X-Content-Type-Options' => 'nosniff',
         'X-XSS-Protection' => '1; mode=block'

  # Adds request routing methods for all http verbs.
  plugin :all_verbs

  # The json_parser plugin parses request bodies in JSON format if the request's content type specifies JSON.
  # This is mostly designed for use with JSON API sites.
  plugin :json_parser

  # It validates authorization token that was passed in Authorization header.
  #
  # @see AuthorizationTokenValidator
  def current_user
    return @current_user if @current_user

    purpose = request.url.include?('refresh_token') ? :refresh_token : :access_token

    @current_user = AuthorizationTokenValidator.new(
      authorization_token: env['HTTP_AUTHORIZATION'],
      purpose: purpose
    ).call
  end

  plugin :hash_routes

  Dir['app/routes/*.rb'].each do |route_file|
    load route_file
  end

  hash_routes.on('api') do |r|
    r.on('v1') do
      r.hash_routes
    end
  end

  route(&:hash_routes)

  FileUtils.mkdir_p(ENV['STORAGE'])
end
