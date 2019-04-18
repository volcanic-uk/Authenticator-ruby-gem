require "base64"

module Volcanic::Authenticator
  module Token

    def expiry_time(token)
      exp = JSON.parse(decode(token))['exp']
      validate_expiry(exp)
    end

    def decode(token)
      tokens = token.split('.')
      return nil unless tokens.length == 3
      return nil if tokens[1].nil? || tokens[1].empty?
      Base64.decode64(tokens[1])
    end

    private

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


