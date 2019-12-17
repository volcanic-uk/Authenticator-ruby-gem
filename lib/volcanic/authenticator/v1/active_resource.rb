# frozen_string_literal: true

require 'forwardable'
require 'active_resource'

module Volcanic::Authenticator
  module V1
    # extend to ActiveResource class
    class ActiveResource < ActiveResource::Base
      extend SingleForwardable
      def_delegator 'Volcanic::Authenticator.config'.to_sym, :auth_enabled?

      # create a dynamic auth header. so every time this class is
      # called, it fetch or generate a new token. New token
      # is generated when token is expired or nil
      cattr_accessor :static_headers
      self.static_headers = headers
      def self.headers
        new_headers = static_headers.clone
        new_headers['Authorization'] = auth_token
        new_headers
      end

      def self.auth_token
        "Bearer #{Volcanic::Authenticator::V1::AppToken.fetch_and_request}" if auth_enabled?
      end
    end
  end
end
