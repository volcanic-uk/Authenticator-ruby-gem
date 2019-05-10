require 'volcanic/authenticator/v1/method'
require 'volcanic/authenticator/config'
require 'mini_cache'

module Volcanic
  # Authenticator
  module Authenticator
    module Base
      def config
        Volcanic::Authenticator::Config
      end

      def cache
        Thread.current[:volcanic_authenticator_cache] ||= MiniCache::Store.new
      end
    end

    extend Base
  end
end
