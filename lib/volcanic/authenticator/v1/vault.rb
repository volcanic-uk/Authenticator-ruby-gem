# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    class Vault < ServiceRequest
      URI = Volcanic::Authenticator.config.vault_url
    end
  end
end
