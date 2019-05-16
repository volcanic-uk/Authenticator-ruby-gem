module Volcanic
  module Authenticator
    ##
    # When token key is missing or invalid (expired, wrong signature, etc..)
    class InvalidToken < StandardError; end
    ##
    # When failed issuing app token (invalid app name or secret)
    class InvalidAppToken < InvalidToken
      def initialize(msg = 'Invalid app identity name or secret')
        super
      end
    end
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
