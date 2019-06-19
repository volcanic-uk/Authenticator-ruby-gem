# frozen_string_literal: true

require_relative '../volcanic.rb'
require_relative 'authenticator/v1/config.rb'
require_relative 'authenticator/v1/exception.rb'

module Volcanic
  # Authenticator
  module Authenticator
    # Token end-point
    GENERATE_TOKEN_URL = 'api/v1/identity/login'
    # Public Key end-point
    PUBLIC_KEY_URL = 'api/v1/key'

    # Authenticator base
    module Base
      def config
        Volcanic::Authenticator::V1::Config
      end
    end

    extend Base
  end
end
