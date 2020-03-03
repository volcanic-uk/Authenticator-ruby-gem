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
    class AuthenticationError < AuthenticatorError; end
    class SignatureError < AuthenticatorError; end
    class ServiceError < AuthenticatorError; end
    class PrincipalError < AuthenticatorError; end
    class IdentityError < AuthorizationError; end
    class TokenError < AuthenticatorError; end
    class PrivilegeError < StandardError; end
    class SubjectError < StandardError; end
    class RoleError < AuthenticatorError; end
    class PermissionError < StandardError; end
    class PermissionGroupError < StandardError; end
    class ScopeError < StandardError; end
  end
end
