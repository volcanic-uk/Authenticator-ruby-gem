# frozen_string_literal: true

require 'httparty'
require 'forwardable'
require 'down'
require_relative 'helper/app_token'

module Volcanic::Authenticator
  module V1
    # service
    class ServiceRequest
      # this method is similar to HTTParty.
      class << self
        def get(*args, &block)
          RequestBase.new(self::KLASS, *args, &block).get
        end

        def post(*args, &block)
          RequestBase.new(self::KLASS, *args, &block).post
        end

        def patch(*args, &block)
          RequestBase.new(self::KLASS, *args, &block).patch
        end

        def put(*args, &block)
          RequestBase.new(self::KLASS, *args, &block).put
        end

        def delete(*args, &block)
          RequestBase.new(self::KLASS, *args, &block).delete
        end

        def download(*args)
          RequestBase.new(self::KLASS).download(*args)
        end
      end

      # request
      class RequestBase
        include HTTParty
        extend Forwardable

        attr_accessor :url, :args, :block
        def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :vault_url, :krakatoa_url, :ats_url, :xenolith_url

        def initialize(klass, *args, &block)
          @args = args
          @block = block
          @url = fetch_url(klass)
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

        def fetch_url(klass)
          case klass
          when :vault
            vault_url
          when :krakatoa
            krakatoa_url
          when :xenoltih
            xenolith_url
          when :ats
            ats_url
          else
            vault_url
          end
        end

        def auth_header
          { 'Authorization' => "Bearer #{AppToken.fetch_and_request}" } if ENV['AUTH_SENDING_TOKEN'] == 'true' || ENV['AUTH_SENDING_TOKEN'].nil?
        end
      end
    end

    class Vault < ServiceRequest
      KLASS = :vault
    end

    class Krakatoa < ServiceRequest
      KLASS = :krakatoa
    end

    class ATS < ServiceRequest
      KLASS = :ats
    end

    class Xenolith < ServiceRequest
      KLASS = :xenolith
    end
  end
end
