# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    class AuthenticatorError < StandardError; end
    ##
    class ConfigurationError < AuthenticatorError; end
    class ApplicationTokenError < AuthenticatorError; end
    ##
    class ConnectionError < AuthenticatorError; end
    class AuthorizationError < AuthenticatorError; end
    class SignatureError < AuthenticatorError; end
    class ServiceError < AuthenticatorError; end
    class PrincipalError < AuthenticatorError; end
    class IdentityError < AuthorizationError; end
    class TokenError < AuthenticatorError; end
  end
end
