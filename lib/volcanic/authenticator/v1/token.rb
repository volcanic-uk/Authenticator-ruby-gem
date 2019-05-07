require 'base64'
require 'jwt'

module Volcanic
  module Authenticator
    module V1
      # Helper for Token handling
      class Token
        attr_accessor :dec_token

        def initialize(token, pem)
          @dec_token = decode token, pem
        end

        def exp
          @dec_token[0]['exp']
        end

        def jti
          @dec_token[0]['jti']
        end

        def valid?
          @dec_token.nil?
        end

        private

        def decode(token, pem)
          return nil if token.nil?

          begin
            pkey = OpenSSL::PKey.read(pem)
            return JWT.decode token, pkey, true, algorithm: 'ES512'
          rescue StandardError
            return nil
          end
        end
      end
    end
  end
end
