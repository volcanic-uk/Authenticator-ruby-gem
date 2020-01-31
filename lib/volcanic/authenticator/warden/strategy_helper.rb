# frozen_string_literal: true

require 'logger'

module Volcanic::Authenticator::Warden
  # Strategy helper module
  module StrategyHelper
    include Warden::Mixins::Common

    attr_reader :token
    attr_writer :logger

    def missing_message
      'Authorization header is missing!'
    end

    def invalid_message
      'Authorization header is invalid!'
    end

    def auth_header_exist?
      request.has_header?('HTTP_AUTHORIZATION')
    end

    def auth_token
      @auth_token ||= fetch_auth_token
    end

    def fetch_auth_token
      bearer, token =
        request.get_header('HTTP_AUTHORIZATION').to_s.split(nil, 2)

      # this will raise TokenError
      return unless bearer.to_s.downcase == 'bearer'

      token
    end

    def session_token
      @session_token ||= fetch_session
    end

    def fetch_session
      session && session[:auth_token]
    end

    def token=(token_base64)
      @token = Volcanic::Authenticator::V1::Token.new(token_base64)
    end

    def token_expired?
      self.token = session_token
      token.exp < Time.now.to_i
    rescue Volcanic::Authenticator::V1::TokenError
      false
    end

    def validate_token
      # if token missing
      return unless token

      if token.remote_validate
        success! token
      else
        fail! invalid_message # invalid token
      end
    end

    def logger
      @logger ||= begin
        defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
      end
    end
  end
end
