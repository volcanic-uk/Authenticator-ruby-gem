require_relative '../volcanic.rb'
require_relative 'authenticator/v1/config.rb'
require_relative 'authenticator/v1/exception.rb'
require_relative 'authenticator/v1/token.rb'

module Volcanic
  # Authenticator
  module Authenticator
    # Authenticator base
    module Base
      def config
        Volcanic::Authenticator::V1::Config
      end
    end

    extend Base
  end
end
