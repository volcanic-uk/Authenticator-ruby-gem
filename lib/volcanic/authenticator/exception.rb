module Volcanic
  module Authenticator
    class InvalidToken < StandardError; end
    class InvalidAppToken < InvalidToken
      def initialize(msg="Invalid app identity name or secret")
        super
      end
    end
    class ValidationError < StandardError; end
    class AuthorizationError < StandardError; end
  end
end
