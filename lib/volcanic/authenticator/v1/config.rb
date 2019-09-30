# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    ##
    # Configuration class
    #
    # after installation of this gem, these need to be configure.
    class Config
      class << self
        # :auth_url is domain url for authenticator service
        # :app_name is the identity name for a service.
        # :app_secret is the identity secret for a service.
        # :app_principal_id is the principal_id use to create a token.
        # :service_name typically the service name.
        attr_accessor :app_name, :app_secret, :app_principal_id, :service_name
        attr_writer :auth_url, :vault_url, :krakatoa_url, :ats_url, :xenolith_url

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

        def vault_url
          @vault_url ||= ENV['VAULT_DOMAIN']
        end

        def krakatoa_url
          @krakatoa_url ||= ENV['KRAKATOA_DOMAIN']
        end

        def ats_url
          @ats_url ||= ENV['ATS_DOMAIN']
        end

        def xenolith_url
          @xenolith_url ||= ENV['XENOLITH_DOMAIN']
        end

        def auth_url
          raise ConfigurationError, 'auth_url cannot be nil.' if @auth_url.nil?

          @auth_url
        end

        private

        def integer?(value)
          value.is_a? Integer
        end
      end
    end
  end
end
