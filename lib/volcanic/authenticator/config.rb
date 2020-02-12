# frozen_string_literal: true

# contain config class
module Volcanic::Authenticator
  # lazy method
  # configuration can be set as:
  # Volcanic::Authenticator.config.auth_url = ''
  #
  # OR
  #
  # Volcanic::Authenticator.config do |config|
  #   config.auth_url = ''
  # end
  def self.config
    yield Volcanic::Authenticator::Config if block_given?
    Volcanic::Authenticator::Config
  end
  ##
  # Configuration class
  #
  # after installation of this gem, these need to be configure.
  class Config
    class << self
      attr_accessor :app_name, :app_secret, :app_dataset_id, :service_name, :debug
      attr_writer :auth_url

      def debug?
        !!debug
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

      def exp_authorize_token
        @exp_authorize_token ||= 5 * 60
      end

      def exp_token=(value)
        raise Volcanic::Authenticator::V1::ConfigurationError unless integer? value

        @exp_token = value.to_i
      end

      def exp_app_token=(value)
        raise Volcanic::Authenticator::V1::ConfigurationError unless integer? value

        @exp_app_token = value.to_i
      end

      def exp_public_key=(value)
        raise Volcanic::Authenticator::V1::ConfigurationError unless integer? value

        @exp_public_key = value.to_i
      end

      def exp_authorize_token=(value)
        raise Volcanic::Authenticator::V1::ConfigurationError unless integer? value

        @exp_authorize_token = value.to_i
      end

      # this is kind of kill switch inside the gem.
      # only accept boolean value
      def auth_enabled=(value)
        raise Volcanic::Authenticator::V1::ConfigurationError, 'auth_enable must be a boolean' unless boolean? value

        @auth_enabled = value
      end

      def auth_enabled?
        @auth_enabled.nil? ? true : @auth_enabled
      end

      def auth_url
        raise Volcanic::Authenticator::V1::ConfigurationError, 'auth_url must not be nil' if @auth_url.nil?

        @auth_url
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
