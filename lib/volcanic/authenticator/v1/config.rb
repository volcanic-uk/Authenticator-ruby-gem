# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    ##
    # Configuration class
    #
    # after installation of this gem, these need to be configure.
    class Config
      class << self
        attr_accessor :app_name, :app_secret, :app_dataset_id, :service_name
        attr_writer :auth_url

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

        def exp_authorize_token
          @exp_authorize_token ||= 5 * 60
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

        def exp_authorize_token=(value)
          raise ConfigurationError unless integer? value

          @exp_authorize_token = value.to_i
        end

        # this is kind of kill switch inside the gem.
        # only accept boolean value
        def auth_enabled=(value)
          raise ConfigurationError, 'auth_enable must be a boolean' unless boolean? value

          @auth_enabled = value
        end

        def auth_enabled?
          @auth_enabled ||= true
        end

        def auth_url
          raise ConfigurationError, 'auth_url must not be nil' if @auth_url.nil?

          @auth_url
        end

        def validate_token_when_presented
          @validate_token_when_presented ||= false
        end

        def validate_token_when_presented=(value)
          raise ConfigurationError, 'validate_token_when_presented must be a boolean' unless boolean? value

          @validate_token_when_presented = value
        end

        def validate_token_always
          @validate_token_always ||= true
        end

        def validate_token_always=(value)
          raise ConfigurationError, 'validate_token_always must be a boolean' unless boolean? value

          @validate_token = value
        end

        private

        def integer?(value)
          value.is_a? Integer
        end

        def boolean?(value)
          [true, false].include? value
        end
      end
    end
  end
end
