require "base64"

module Volcanic::Authenticator
  class Token

    # attr_accessor :token

    def initialize(token)
      @token = token
    end

    def decode
      tokens = @token.split('.')
      return nil unless tokens.length == 3
      return nil if tokens[1].nil? || tokens[1].empty?
      Base64.decode64(tokens[1])
    end

    def expiry_time
      exp = JSON.parse(decode)['exp']
      validate_expiry(exp)
    end

    private

    def validate_expiry(exp)
      token_exp = exp.to_i
      default_exp = (Time.now + ENV['expiry_hour'].to_i * 60 * 60).to_i

      return default_exp if token_exp < Time.now.to_i
      return token_exp if token_exp < default_exp
      default_exp
    end

  end
end


