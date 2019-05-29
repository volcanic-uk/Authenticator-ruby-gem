require_relative '../volcanic.rb'
require_relative 'authenticator/config.rb'
require_relative 'authenticator/exception.rb'
require_relative 'authenticator/v1/identity'
require_relative 'authenticator/v1/principal'
require_relative 'authenticator/v1/token'

module Volcanic
  # Authenticator
  module Authenticator
    PUBLIC_KEY = 'volcanic_public_key'.freeze
    APP_TOKEN = 'volcanic_application_token'.freeze
    IDENTITY_REGISTER = 'api/v1/identity'.freeze
    IDENTITY_LOGIN = 'api/v1/identity/login'.freeze
    IDENTITY_LOGOUT = 'api/v1/identity/logout'.freeze
    IDENTITY_DEACTIVATE = 'api/v1/identity/deactivate'.freeze
    IDENTITY_VALIDATE = 'api/v1/identity/validate'.freeze
    PUBLIC_KEY_GENERATE = 'api/v1/key'.freeze
    ##
    # config helper
    module Base
      def config
        Volcanic::Authenticator::Config
      end
    end

    extend Base
  end
end
