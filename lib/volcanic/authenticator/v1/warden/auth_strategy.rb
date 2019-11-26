# frozen_string_literal: true

require 'warden'
require 'forwardable'
require_relative '../token'

module Volcanic::Authenticator
  module V1::Warden
    # this class handle the auth service authentication by using warden
    class AuthStrategy < Warden::Strategies::Base
      private

      def validate_token
        token = Volcanic::Authenticator::V1::Token.new(auth_token)
        if token.remote_validate
          success!(token)
        else
          invalid!
        end
      rescue Volcanic::Authenticator::V1::TokenError
        invalid!
      rescue Volcanic::Authenticator::V1::ConnectionError => e
        fail!(e)
      end

      def auth_token
        @auth_token ||= env['HTTP_AUTHORIZATION'].to_s.gsub('Bearer ', '')
      end

      def invalid!
        fail! 'Authorization header is invalid!'
      end

      def missing!
        fail! 'Authorization header is missing!'
      end
    end
  end
end
