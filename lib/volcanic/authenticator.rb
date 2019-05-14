require 'volcanic/authenticator/v1/identity'
require 'volcanic/authenticator/config'
require 'volcanic/authenticator/exception'

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
