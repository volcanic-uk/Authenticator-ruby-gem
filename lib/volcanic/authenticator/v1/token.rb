# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Token class
    class Token
      attr_accessor :token_base64

      def initialize(token)
        @token_base64 = token
      end
    end
  end
end
