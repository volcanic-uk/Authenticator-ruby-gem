require 'httparty'
require_relative 'header'
require_relative 'app_token'

module Volcanic::Authenticator
  module V1
    ##
    # Request helper
    module Request
      include Header
      extend Header

      # performing post method request
      def perform_post_request(end_point, body = nil, auth_token = AppToken.fetch_and_request)
        url = [Volcanic::Authenticator.config.auth_url, end_point].join('/')
        HTTParty.post url, body: body, headers: bearer_header(auth_token)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      # performing get method request
      def perform_get_request(end_point)
        url = [Volcanic::Authenticator.config.auth_url, end_point].join('/')
        auth_token = AppToken.fetch_and_request
        HTTParty.get url, headers: bearer_header(auth_token)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      # performing delete method request
      def perform_delete_request(end_point)
        url = [Volcanic::Authenticator.config.auth_url, end_point].join('/')
        auth_token = AppToken.fetch_and_request
        HTTParty.delete url, headers: bearer_header(auth_token)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end
    end
  end
end
