require_relative '../volcanic.rb'
require_relative 'authenticator/config.rb'
require_relative 'authenticator/exception.rb'
require_relative 'authenticator/v1/identity'
require_relative 'authenticator/v1/principal'

module Volcanic
  # Authenticator
  module Authenticator
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
