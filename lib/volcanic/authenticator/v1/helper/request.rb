# frozen_string_literal: true

require 'httparty'
require_relative 'header'
require_relative 'error'
require_relative 'app_token'

module Volcanic::Authenticator
  module V1
    # Request helper
    module Request
      include Header
      include Error

      def self.included(base)
        base.extend self
      end

      # performing post method request
      def perform_post_and_parse(exception, end_point, body = nil, auth_token = AppToken.fetch_and_request)
        url = [Volcanic::Authenticator.config.auth_url, end_point].join('/')
        res = HTTParty.post url, body: body, headers: bearer_header(auth_token)
        exception_handler_and_parser(exception, res)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      # performing get method request
      def perform_get_and_parse(exception, end_point, auth_token = AppToken.fetch_and_request)
        url = [Volcanic::Authenticator.config.auth_url, end_point].join('/')
        res = HTTParty.get url, headers: bearer_header(auth_token)
        exception_handler_and_parser(exception, res)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      # performing delete method request
      def perform_delete_and_parse(exception, end_point)
        url = [Volcanic::Authenticator.config.auth_url, end_point].join('/')
        auth_token = AppToken.fetch_and_request
        res = HTTParty.delete url, headers: bearer_header(auth_token)
        exception_handler_and_parser(exception, res)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      def exception_handler_and_parser(exception, res)
        send(exception, res) unless res.success?
        JSON.parse(res.body)['response']
      end
    end
  end
end
