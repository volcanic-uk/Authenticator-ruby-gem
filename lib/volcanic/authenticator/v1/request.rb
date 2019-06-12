require 'httparty'
require_relative 'header'
require_relative 'token_key'

module Volcanic::Authenticator
  module V1
    ##
    # Request helper
    module Request
      include Header
      extend Header

      def perform_post_request(end_point, body = nil, header = TokenKey.fetch_and_request_app_token)
        url = Volcanic::Authenticator.config.auth_url
        HTTParty.post "#{url}/#{end_point}", body: body, headers: bearer_header(header)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end

      def perform_get_request(end_point)
        url = Volcanic::Authenticator.config.auth_url
        HTTParty.get "#{url}/#{end_point}", headers: bearer_header(TokenKey.fetch_and_request_app_token)
      rescue Timeout::Error, Errno::EINVAL, Errno::ECONNREFUSED, Errno::ECONNRESET, EOFError => e
        raise ConnectionError, e
      end
    end
  end
end
