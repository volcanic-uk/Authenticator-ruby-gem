# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    ##
    # Configuration class
    #
    # after installation of this gem, these need to be configure.
    class Config
      class << self
        attr_accessor :auth_url, :app_name, :app_secret
        attr_writer :key_store_type

        # currently auth service has 2 types of key_store
        # Dynamic and Static. Generally this is regarding to key rotation.
        # After the key rotation features is finalise, this will be remove.
        # Only dynamic key will be use.
        def key_store_type
          @key_store_type ||= 'static'
        end

        # expiration time of cache tokens
        def exp_token
          @exp_token ||= 5 * 60 # default of 5 minutes
        end

        # expiration time of cache application token
        def exp_app_token
          @exp_app_token ||= 24 * 60 * 60 # default of 1 day
        end

        # expiration time of cache public keys
        def exp_public_key
          @exp_public_key ||= 24 * 60 * 60 # default of 1 day
        end

        def exp_token=(value)
          raise ConfigurationError unless integer? value

          @exp_token = value.to_i
        end

        def exp_app_token=(value)
          raise ConfigurationError unless integer? value

          @exp_app_token = value.to_i
        end

        def exp_public_key=(value)
          raise ConfigurationError unless integer? value

          @exp_public_key = value.to_i
        end

        private

        def integer?(value)
          value.is_a? Integer
        end
      end
    end
  end
end
