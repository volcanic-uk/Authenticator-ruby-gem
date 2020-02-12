# frozen_string_literal: true

require 'oj'
require_relative 'common'

module Volcanic::Authenticator::V1
  # Privilege
  # Used for returning privileges from the Auth Service
  class Privilege < Common
    class << self
      def find_by_service(service)
        response.find(-> { raise PrivilegeError, "Could not find privileges for service \"#{service}\"" }) { |s| s['name'] == service }
      end

      private

      # When the auth service is queryable by service, ditch the method below
      def response
        @response ||= json['response']
      end

      def json
        @json ||= Oj.load(File.open('lib/support/json/privileges.json'))
      end
    end
  end
end
