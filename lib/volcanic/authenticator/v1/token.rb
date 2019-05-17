require 'jwt'

module Volcanic
  module Authenticator
    module V1
      # Helper for Token handling
      class Token
        def initialize(token, pkey)
          @dec_token = decode token, pkey
        end

        def jti
          @dec_token[0]['jti']
        end

        private

        def decode(token, pkey)
          JWT.decode token, pkey, true, algorithm: 'ES512'
        rescue JWT::DecodeError
          raise InvalidTokenError
        end
      end
    end
  end
end
