module Volcanic
  module Authenticator
    ##
    # Config class
    class Config
      ##
      # singleton
      class << self
        attr_accessor :auth_url, :app_name, :app_secret
        # attr_reader :exp_token, :exp_app_token, :exp_public_key

        def exp_token
          @expire_token ||= 5 * 60
        end

        def exp_app_token
          @expire_app_token ||= 24 * 60 * 60
        end

        def exp_public_key
          @expire_public_key ||= 24 * 60 * 60
        end

        def exp_token=(value)
          raise ExpTokenError unless integer? value

          @expire_token = value.to_i
        end

        def exp_app_token=(value)
          raise ExpAppTokenError unless integer? value

          @expire_app_token = value.to_i
        end

        def exp_public_key=(value)
          raise ExpPublicKeyError unless integer? value

          @expire_public_key = value.to_i
        end

        private

        def integer?(value)
          value.is_a? Integer
        end
      end
    end
  end
end
