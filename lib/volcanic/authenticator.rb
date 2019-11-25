# frozen_string_literal: true

require_relative '../volcanic'
require_relative 'authenticator/v1/config'
require_relative 'authenticator/v1/exception'
require_relative 'authenticator/v1/helper/app_token'
require_relative 'authenticator/v1/helper/key'
require_relative 'authenticator/v1/service.rb'
require_relative 'authenticator/v1/http_request'
require_relative 'authenticator/v1/resource.rb'
require_relative 'authenticator/v1/principal.rb'
require_relative 'authenticator/v1/identity.rb'
require_relative 'authenticator/v1/token.rb'

module Volcanic
  # Authenticator
  module Authenticator
    # Authenticator base
    module Base
      def config
        Volcanic::Authenticator::V1::Config
      end

      # handling multiple configurations
      # Volcanic::Authenticator.setup do |config|
      #   config.auth_url = 'auth.com'
      #   config.auth_enabled = true
      # end
      def setup
        yield Volcanic::Authenticator::V1::Config
      end
    end

    extend Base
  end
end
