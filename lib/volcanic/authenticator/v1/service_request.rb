# frozen_string_literal: true

require 'httparty'
require_relative 'helper/app_token'

module Volcanic::Authenticator
  module V1
    # service
    class ServiceRequest
      # this method is similar to HTTParty.
      class << self
        def get(*args, &block)
          RequestBase.new(self::URI, *args, &block).get
        end

        def post(*args, &block)
          RequestBase.new(self::URI, *args, &block).post
        end

        def patch(*args, &block)
          RequestBase.new(self::URI, *args, &block).patch
        end

        def put(*args, &block)
          RequestBase.new(self::URI, *args, &block).put
        end

        def delete(*args, &block)
          RequestBase.new(self::URI, *args, &block).delete
        end

        def download(*args)
          RequestBase.new(self::URI).download(*args)
        end
      end

      # request
      class RequestBase
        include HTTParty

        attr_accessor :uri, :args, :block

        def initialize(uri, *args, &block)
          @args = args
          @block = block
          @uri = uri
          self.class.base_uri uri
          self.class.headers auth_header
        end

        def get
          self.class.get(*args, &block)
        end

        def post
          self.class.post(*args, &block)
        end

        def put
          self.class.put(*args, &block)
        end

        def patch
          self.class.patch(*args, &block)
        end

        def delete
          self.class.delete(*args, &block)
        end

        def download(endpoint, **opts)
          # path = [uri, endpoint].join
          # opts[:headers] = auth_header
          # Down.download(path, opts)
        end

        private

        def auth_header
          @auth_header ||= { 'Authorization' => "Bearer #{AppToken.fetch_and_request}" }
        end
      end
    end
  end
end
