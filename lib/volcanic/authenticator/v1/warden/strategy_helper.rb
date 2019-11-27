# frozen_string_literal: true

require 'warden'
require_relative '../token'

module Volcanic::Authenticator
  module V1::Warden
    # this class handle the auth service authentication by using warden
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

      def authorization_header
        request.get_header('HTTP_AUTHORIZATION').to_s.gsub('Bearer ', '')
      end

      def token
        @token ||= Volcanic::Authenticator::V1::Token.new(authorization_header)
      end

      def token_valid?
        @token_valid.nil? ? @token_valid = token.remote_validate : @token_valid
      end
    end
  end
end
