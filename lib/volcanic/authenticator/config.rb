module Volcanic
  module Authenticator
    class Config
      ##
      # setup Authenticator domain url
      def auth_url
        @@auth_url ||= 'http://0.0.0.0:3000'
      end

      def auth_url=(value)
        @@auth_url = value
      end

      ##
      # setup identity name
      def identity_name
        @@identity_name ||= 'Volcanic'
      end

      def identity_name=(value)
        @@identity_name = value
      end

      ##
      # setup identity_secret
      def identity_secret
        @@identity_secret ||= '3ddaac80b5830cef8d5ca39d958954b3f4afbba2'
      end

      def identity_secret=(value)
        @@identity_secret = value
      end

      ##
      # setup expire time fot token
      def exp_token
        @@exp_token ||= 5 * 60 # default 5 minutes
      end

      def exp_token=(value)
        return unless is_number? value

        @@exp_token = value.to_i
      end

      ##
      # setup expire time for main token
      def exp_main_token
        @@exp_main_token ||= 24 * 60 * 60 # default 1 day
      end

      def exp_main_token=(value)
        return unless is_number? value

        @@exp_main_token = value.to_i
      end

      ##
      # setup expire time for public key
      def exp_public_key
        @@exp_public_key ||= 24 * 60 * 60 # default 1 day
      end

      def exp_public_key=(value)
        return unless is_number? value

        @@exp_public_key = value.to_i
      end

      private

      def is_number?(obj)
        obj.to_s == obj.to_i.to_s
      end
    end
  end
end

