module Volcanic
  module Authenticator
    class Config
      class << self
        attr_accessor :auth_url, :identity_name, :identity_secret
        attr_reader :exp_token, :exp_main_token, :exp_public_key

        def exp_token=(value)
          return unless number? value

          @exp_token = value.to_i
        end

        def exp_main_token=(value)
          return unless number? value

          @exp_main_token = value.to_i
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
