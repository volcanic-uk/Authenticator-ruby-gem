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

      # rubocop:disable Metrics/MethodLength
      def perform_request_and_parse(verb, exception, end_point, body = nil, auth_token = :undefined)
        cached_token = auth_token == :undefined
        retries = 0
        begin
          auth_token = AppToken.fetch_and_request if cached_token
          res = HTTParty.send verb, url_for(end_point), body: body, headers: bearer_header(auth_token),
            debug_output: $stdout
          exception_handler_and_parser(exception, res)
        rescue Volcanic::Authenticator::V1::AuthenticationError => e
          if retries < 2 && cached_token
            AppToken.invalidate_cache!
            retries += 1
            retry
          end
          raise e
        end
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end
      # rubocop:enable Metrics/MethodLength

      def perform_post_and_parse(exception, end_point, body = nil, auth_token = :undefined)
        perform_request_and_parse(:post, exception, end_point, body, auth_token)
      end

      # performing get method request
      def perform_get_and_parse(exception, end_point, auth_token = :undefined)
        perform_request_and_parse(:get, exception, end_point, nil, auth_token)
      end

      # performing delete method request
      def perform_delete_and_parse(exception, end_point, auth_token = :undefined)
        perform_request_and_parse(:delete, exception, end_point, nil, auth_token)
      end

      def exception_handler_and_parser(exception, res)
        RaiseException.new(res, exception) unless res.success?
        JSON.parse(res.body)['response']
      end

      def url_for(end_point)
        [Volcanic::Authenticator.config.auth_url, end_point].join('/')
      end
    end
  end
end
