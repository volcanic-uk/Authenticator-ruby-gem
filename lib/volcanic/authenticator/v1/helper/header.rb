# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Header helper
    module Header
      # when include this module, it will extend it too
      def self.included(base)
        base.extend self
      end

      def bearer_header(token)
        { 'Authorization' => "Bearer #{token}",
          'Content-Type' => 'application/json' }
      end
    end
  end
end
