module Volcanic
  module Authenticator
    ##
    # Config class
    class Config
      ##
      # singleton
      class << self
        attr_accessor :auth_url, :app_name, :app_secret
        attr_reader :exp_token, :exp_app_token, :exp_public_key

        def exp_token=(value)
          return unless number? value

          @exp_token = value.to_i
        end

        def exp_app_token=(value)
          return unless number? value

          @exp_app_token = value.to_i
        end

        def exp_public_key=(value)
          return unless number? value

          @exp_public_key = value.to_i
        end

        private

        def number?(obj)
          obj.to_s == obj.to_i.to_s
        end
      end
    end
  end
end
