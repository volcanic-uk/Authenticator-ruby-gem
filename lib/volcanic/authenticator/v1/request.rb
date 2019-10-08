# frozen_string_literal: true

require 'httparty'
require 'forwardable'
require 'down'
require_relative 'helper/app_token'

module Volcanic::Authenticator
  module V1
    # This class use HTTParty for the http request.
    # only that it has an 'Authorization' header that is needed for auth service
    #
    # eg.
    #
    # Request.get('/api/v1/user', body: {id: '1'}.to_json, headers: {'Content-Type' => '...'})
    #
    # to extend class:
    #
    # VaultRequest < Request
    #   BASE_URI = 'http://abc.com/'
    # end
    #
    # VaultRequest.get('api/v1/user')
    #
    class Request
      class << self
        def get(*args, &block)
          RequestBase.new(self::BASE_URI, *args, &block).get
        end

        def post(*args, &block)
          RequestBase.new(self::BASE_URI, *args, &block).post
        end

        def patch(*args, &block)
          RequestBase.new(self::BASE_URI, *args, &block).patch
        end

        def put(*args, &block)
          RequestBase.new(self::BASE_URI, *args, &block).put
        end

        def delete(*args, &block)
          RequestBase.new(self::BASE_URI, *args, &block).delete
        end

        def download(*args)
          RequestBase.new(self::BASE_URI).download(*args)
        end
      end

      # request
      class RequestBase
        include HTTParty
        extend Forwardable

        attr_accessor :url, :args, :block
        def_instance_delegator 'Volcanic::Authenticator.config'.to_sym, :auth_enabled?

        def initialize(base_url, *args, &block)
          @args = args
          @block = block
          @url = base_url
          self.class.base_uri url
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
          path = [url, endpoint].join
          opts[:headers] = auth_header
          Down.download(path, opts)
        end

        private

        def auth_header
          { 'Authorization' => "Bearer #{AppToken.fetch_and_request}" } if auth_enabled?
        end
      end
    end
  end
end
