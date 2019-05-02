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
          perform_get_claim 'exp'
        end

        def jti
          perform_get_claim 'jti'
        end

        def valid?
          @dec_token.nil?
        end

        private

        def perform_get_claim(object)
          return nil if @dec_token.nil?

          JSON.parse(@dec_token.to_json)[0][object.to_s]
        end

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
