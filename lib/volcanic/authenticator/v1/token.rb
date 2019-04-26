require 'base64'

module Volcanic
  module Authenticator
    # Helper for Token handling
    module Token
      def expiry_time(token)
        perform_get_claim token, 'exp'
      end

      def jti(token)
        perform_get_claim token, 'jti'
      end

      private

      def perform_get_claim(token, object)
        decoded = decode token
        return nil if decoded.nil?

        JSON.parse(decoded)[object]
      end

      def validate_expiry(exp)
        token_exp = exp.to_i
        exp_hour = ENV['volcanic_authenticator_redis_expiry_time'] || 5
        default_exp = (Time.now + exp_hour.to_i * 60 * 60).to_i
        return default_exp if token_exp < Time.now.to_i
        return token_exp if token_exp < default_exp

        default_exp
      end

      def decode(token)
        return nil if token.nil?

        tokens = token.split('.')
        return nil unless tokens.length == 3
        return nil if tokens[1].nil? || tokens[1].empty?

        begin
          Base64.decode64(tokens[1])
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
