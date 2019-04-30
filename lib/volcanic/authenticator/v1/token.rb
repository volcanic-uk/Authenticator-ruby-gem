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

        def validate_expiry(exp)
          token_exp = exp.to_i
          exp_hour = ENV['volcanic_authenticator_redis_expiry_time'] || 5
          default_exp = (Time.now + exp_hour.to_i * 60 * 60).to_i
          return default_exp if token_exp < Time.now.to_i
          return token_exp if token_exp < default_exp

          default_exp
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
