require 'base64'
require 'jwt'

module Volcanic
  module Authenticator
    # Helper for Token handling
    module Token
      def expiry_time(token)
        exp = JSON.parse(decode(token))['exp']
        validate_expiry(exp)
      end

      def self.decrypt(token)
        JWT.decode token, public_key, true, algorithm: 'ES512'
      end

      def decode(token)
        tokens = token.split('.')
        return nil unless tokens.length == 3
        return nil if tokens[1].nil? || tokens[1].empty?

        Base64.decode64(tokens[1])
      end

      private

      def public_key
        "-----BEGIN PUBLIC KEY-----\nMIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQARs3UaQ82aORFh4BMUstcXHV85KT+\n6ZgAiWswUiGiAPvvrt4DPBj1MM81uSt46AKLllybGgjDbmxsxKR6GJxZZSsAbhRo\n351VCzTAc3IrzYpXAkvwpH5xpN0HEUFqYfdB54fz5EsV9Ib97lNCKceGUJH4fotS\nPnFgCjz0Z094WOKNimI=\n-----END PUBLIC KEY-----"
      end

      def validate_expiry(exp)
        token_exp = exp.to_i
        exp_hour = ENV['volcanic_authenticator_redis_expiry_time'] || 5
        default_exp = (Time.now + exp_hour.to_i * 60 * 60).to_i
        return default_exp if token_exp < Time.now.to_i
        return token_exp if token_exp < default_exp

        default_exp
      end
    end
  end
end
