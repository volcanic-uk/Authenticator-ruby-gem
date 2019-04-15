require "base64"

module Volcanic::Authenticator
  module Token
    def self.decode(token)
      tokens = token.split('.')
      return nil unless tokens.length == 3
      return nil if tokens[1].nil? || tokens[1].empty?
      Base64.decode64(tokens[1])
    end

  end
end


