# frozen_string_literal: true

require_relative 'resource_base'

module Volcanic::Authenticator
  module V1
    module Resource
      # this class extend ActiveResource and fetch_and_request
      # token for authentication header.
      class ResourceBase < ActiveResource::Base
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
          "Bearer #{Volcanic::Authenticator::V1::AppToken.fetch_and_request}"
        end

        def self.endpoint=(endpoint)
          self.site = endpoint
        end
      end

      # eg.
      # class User < Resource::Vault
      #   self.path = '/api/v1/...'
      # end
      class Vault < ResourceBase
        def self.path=(path)
          self.endpoint = [ENV['VAULT_DOMAIN'], path].join
        end
      end

      class Krakatoa < ResourceBase
        def self.path=(path)
          self.endpoint = [ENV['KRAKATOA_DOMAIN'], path].join
        end
      end

      class ATS < ResourceBase
        def self.path=(path)
          self.endpoint = [ENV['ATS_DOMAIN'], path].join
        end
      end

      class Xenolith < ResourceBase
        def self.path=(path)
          self.endpoint = [ENV['XENOLITH_DOMAIN'], path].join
        end
      end
    end
  end
end
