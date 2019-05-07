require 'volcanic/authenticator/v1/method'
require 'volcanic/authenticator/config'
require 'mini_cache'

module Volcanic
  # Authenticator
  module Authenticator
    module Base
      def config
        Thread.current[:volcanic_authenticator_config] ||= Volcanic::Authenticator::Config.new
      end

      def cache
        Thread.current[:volcanic_authenticator_cache] ||= MiniCache::Store.new
      end
    end

    extend Base
  end
end
