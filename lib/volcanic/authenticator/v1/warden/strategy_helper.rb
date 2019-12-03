# frozen_string_literal: true

require 'warden'
require_relative '../token'

module Volcanic::Authenticator
  module V1::Warden
    # Strategy helper module
    module StrategyHelper
      include Warden::Mixins::Common

      def missing_message
        'Authorization header is missing!'
      end

      def invalid_message
        'Authorization header is invalid!'
      end

      def token_exist?
        request.has_header?('HTTP_AUTHORIZATION')
      end

      def fetch_token
        bearer, token =
          request.get_header('HTTP_AUTHORIZATION').to_s.split(nil, 2)

        # this will raise TokenError
        return unless valid_bearer?(bearer)

        token
      end

      def valid_bearer?(value)
        value.downcase == 'bearer'
      end

      def token
        @token ||= Volcanic::Authenticator::V1::Token.new(fetch_token)
      end

      def token_valid?
        @token_valid.nil? ? @token_valid = token.remote_validate : @token_valid
      end
    end
  end
end
