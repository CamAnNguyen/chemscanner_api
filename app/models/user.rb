# frozen_string_literal: true

# User model
class User < Sequel::Model
  # Plugin that adds BCrypt authentication and password hashing to Sequel models.
  plugin :secure_password

  # Validates {User} object.
  def validate
    super

    validates_format(Constants::EMAIL_REGEX, :email) if email
  end
end
