module Volcanic
  module Authenticator
    ##
    # When token key is missing or invalid (expired, wrong signature, etc..)
    class InvalidTokenError < StandardError; end
    ##
    # When failed issuing app token (invalid app name or secret)
    class InvalidAppIdentityError < InvalidTokenError
      def initialize(msg = 'Invalid app identity name or secret')
        super
      end
    end
    ##
    # When failed issuing/login identity, due to wrong credentials or identity suspended
    class InvalidIdentityError < InvalidTokenError; end
    ##
    # When http response 400 (missing or wrong type of parameters)
    class ValidationError < StandardError; end
    ##
    # When authorization header is missing or invalid (expired, wrong signature, etc..)
    class AuthorizationError < StandardError; end
    ##
    # When missing or invalid authentication url
    # When .deactivate missing identity id at path.
    class URLError < StandardError; end
  end
end
