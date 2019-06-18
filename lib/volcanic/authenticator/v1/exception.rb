module Volcanic::Authenticator
  module V1
    class AuthenticatorError < StandardError; end
    class ConfigurationError < AuthenticatorError; end
  end
end
