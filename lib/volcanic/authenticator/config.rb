module Volcanic::Authenticator
  ##
  # Config class
  class Config
    ##
    # singleton
    class << self
      attr_accessor :auth_url, :app_name, :app_secret
      attr_writer :app_issuer
      # attr_reader :exp_token, :exp_app_token, :exp_public_key

      def app_issuer
        @app_issuer ||= 'volcanic'
      end

      def exp_token
        @exp_token ||= 5 * 60
      end

      def exp_app_token
        @exp_app_token ||= 24 * 60 * 60
      end

      def exp_public_key
        @exp_public_key ||= 24 * 60 * 60
      end

      def exp_token=(value)
        raise ExpTokenError unless integer? value

        @exp_token = value.to_i
      end

      def exp_app_token=(value)
        raise ExpAppTokenError unless integer? value

        @exp_app_token = value.to_i
      end

      def exp_public_key=(value)
        raise ExpPublicKeyError unless integer? value

        @exp_public_key = value.to_i
      end

      private

      def integer?(value)
        value.is_a? Integer
      end
    end
  end
end
