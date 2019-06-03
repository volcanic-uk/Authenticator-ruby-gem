module Volcanic::Authenticator
  class AuthenticatorError < StandardError; end
  ##
  # When token key is missing or invalid (expired, wrong signature, etc..)
  class TokenError < AuthenticatorError; end
  ##
  # When failed issuing/login identity, due to wrong credentials (name or secret) or identity suspended
  class IdentityError < AuthenticatorError; end
  ##
  # When principal error occurs
  class PrincipalError < AuthenticatorError; end
  ##
  # When http response 400 (missing or wrong type of parameters)
  class ValidationError < AuthenticatorError; end
  ##
  # When authorization header is missing or invalid (expired, wrong signature, etc..)
  class AuthorizationError < AuthenticatorError; end
  ##
  # When missing or invalid authentication url
  # When .deactivate missing identity id at path.
  class ConnectionError < AuthenticatorError; end
  ##
  # When authenticator server return 5xx
  class ServerError < AuthenticatorError
    def initialize(msg = 'Authenticator server error.')
      super
    end
  end
  ##
  # When Public KEY issue occurs
  class KeyError < AuthenticatorError; end

  ##
  # Invalid or missing(required ones) configurations.
  class ConfigurationError < AuthenticatorError; end
  ##
  # When parsing invalid integer values to config.exp_token
  class ExpTokenError < ConfigurationError
    def initialize(msg = 'Getting non-integer value. Please check your configurations.')
      super
    end
  end
  ##
  # When parsing invalid integer values to config.exp_app_token
  class ExpAppTokenError < ConfigurationError
    def initialize(msg = 'Getting non-integer value. Please check your configurations.')
      super
    end
  end
  ##
  # When parsing invalid integer values to config.exp_public_key
  class ExpPublicKeyError < ConfigurationError
    def initialize(msg = 'Getting non-integer value. Please check your configurations.')
      super
    end
  end
  ##
  # When parsing invalid application identity name or secret (config.app_name or config.app_secret)
  class ApplicationError < ConfigurationError
    def initialize(msg = 'Invalid app identity name or secret. Please check your configurations.')
      super
    end
  end
  ##
  # Arguments error
  class ArgumentError < AuthenticatorError; end
end
