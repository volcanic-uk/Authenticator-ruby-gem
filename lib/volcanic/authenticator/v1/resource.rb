# frozen_string_literal: true

require 'forwardable'

module Volcanic::Authenticator
  module V1
    module Resource
      # this class extend ActiveResource and fetch_and_request
      # token for authentication header.
      class ResourceBase < ActiveResource::Base
        extend SingleForwardable
        def_delegators 'Volcanic::Authenticator.config'.to_sym, :vault_url, :krakatoa_url, :ats_url, :xenolith_url

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
      #
      # when calling vault using resource
      class Vault < ResourceBase
        def self.path=(path)
          self.endpoint = [vault_url, path].join
        end
      end

      # when calling Krakatoa using resource
      class Krakatoa < ResourceBase
        def self.path=(path)
          self.endpoint = [krakatoa_url, path].join
        end
      end

      # when calling ATS using resource
      class ATS < ResourceBase
        def self.path=(path)
          self.endpoint = [ats_url, path].join
        end
      end

      # when calling Xenoith using resource
      class Xenolith < ResourceBase
        def self.path=(path)
          self.endpoint = [xenolith_url, path].join
        end
      end
    end
  end
end
