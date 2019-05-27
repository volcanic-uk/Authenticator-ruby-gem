require 'httparty'
require 'forwardable'
require_relative 'error_response'
require_relative 'header'
require_relative 'token'

module Volcanic::Authenticator
  module V1
    ##
    # This is Principal Api class
    class Principal
      include HTTParty
      extend SingleForwardable

      # URLS
      CREATE_URL = ''
      UPDATE_URL = ''
      DELETE_URL = ''

      @_singleton_mutex = Mutex.new

      class << self
        def instance
          @_singleton_mutex.synchronize { @_singleton_instance ||= new }
        end
      end

      def initialize
        self.class.base_uri Volcanic::Authenticator.config.auth_url
      end

      def create; end

      def update; end

      def delete; end

      private

      def request_create_principal
        self.class.post(CREATE_URL)
      end

      def request_update_principal
        self.class.post(UPDATE_URL)
      end

      def request_delete_principal
        self.class.delete(DELETE_URL)
      end
    end
  end
end
