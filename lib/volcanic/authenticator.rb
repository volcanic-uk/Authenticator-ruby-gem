require 'volcanic/authenticator/v1/method'
require 'volcanic/authenticator/config'

module Volcanic
  # Authenticator
  module Authenticator
    module Base
      def config
        Volcanic::Authenticator::Config
      end
    end

    extend Base
  end
end
