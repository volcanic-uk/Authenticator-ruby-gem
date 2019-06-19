# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    class AuthenticatorError < StandardError; end
    ##
    class ConfigurationError < AuthenticatorError; end
    class ApplicationTokenError < AuthenticatorError; end
    ##
    class ConnectionError < AuthenticatorError; end
    class AuthorisationError < AuthenticatorError; end
    class SignatureError < AuthenticatorError; end
  end
end
