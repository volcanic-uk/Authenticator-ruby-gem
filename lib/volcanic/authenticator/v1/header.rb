module Volcanic::Authenticator
  module Header
    def self.bearer(token)
      "Bearer #{token}"
    end
  end
end
