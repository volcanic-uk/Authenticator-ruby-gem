# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    #
    # Privileges api
    class Privilege
      include Request
      include Error

      PRIVILEGE_URL = 'api/v1/privileges'
      EXCEPTION = :raise_exception_privilege

      attr_reader :id, :subject_id
      attr_accessor :scope, :permission_id, :group_id

      #
      # initialize new privilege
      def initialize(id:, scope: nil, permission_id: nil, group_id: nil, **opts)
        @id = id
        @scope = scope
        @permission_id = permission_id
        @group_id = group_id
        @subject_id = opts[:subject_id]
        @allow = opts[:allow]
      end

      #
      # to check if privilege is allowed not not
      # eg.
      #   privilege = Privilege.find_by_id(1)
      #   privilege.allow? # => true
      #
      def allow?
        @allow == 1
      end

      #
      # to allow a privilege
      # eg.
      #   privilege = Privilege.find_by_id(1)
      #   privilege.allow!
      #
      #   prv = Privilege.find_by_id(1)
      #   prv.allow? #=> true
      #
      def allow!
        return if allow?

        update(allow: 1)
        @allow = 1
      end

      #
      # to disallow a privilege
      # eg.
      #   privilege = Privilege.find_by_id(1)
      #   privilege.disallow!
      #
      #   prv = Privilege.find_by_id(1)
      #   prv.allow? #=> false
      #
      def disallow!
        return unless allow?

        update(allow: 0)
        @allow = 0
      end

      #
      # Update privilege
      # eg.
      #   privilege = Privilege.find_by_id(1)
      #   privilege.scope = 'update scope'
      #   privilege.permission_id = 2
      #   privilege.group_id = 10
      #   privilege.save
      #
      def save
        update(scope: scope,
               permission_id: permission_id,
               group_id: group_id)
      end

      #
      # Delete privilege
      #  eg.
      #   privilege = Privilege.find_by_id(1)
      #   privilege.delete
      #
      def delete
        perform_delete_and_parse EXCEPTION, "#{PRIVILEGE_URL}/#{id}"
      end

      class << self
        include Request
        include Error
        #
        # to create new privilege
        # Eg.
        #  privilege = Privilege.create(SCOPE, PERMISSION_ID,GROUP_ID)
        #  privilege.scope # => 'scope for this privilege'
        #  privilege.id # => 1
        #  privilege.permission_id # => 10
        #  privilege.group_id # => 2
        #
        def create(scope, permission_id, group_id = nil)
          payload = { scope: scope,
                      permission_id: permission_id,
                      group_id: group_id }.to_json
          parsed = perform_post_and_parse EXCEPTION, PRIVILEGE_URL, payload
          new(parsed.transform_keys(&:to_sym))
        end

        #
        # to receive an array of privileges
        #
        # eg.
        #   privileges = privilege.find
        #   privileges[0].name # => 'privilege-a'
        #   privileges[0].id # => '<privilege_ID>'
        #   ....
        #
        def find(key_scope: '', page: 1, page_size: 10)
          params = %W[query=#{key_scope} page=#{page} page_size#{page_size}]
          url = "#{PRIVILEGE_URL}?#{params.join('&')}"
          parsed = perform_get_and_parse EXCEPTION, url
          parsed['data'].map { |data| new(data.transform_keys(&:to_sym)) }
        end

        #
        # to find by given id
        #
        # eg.
        #   privilege = privilege.find_by_id(1)
        #   privilege.name # => 'privilege-a'
        #   privilege.id # => 1
        #   ....
        #
        def find_by_id(id)
          raise ArgumentError, 'argument is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse EXCEPTION, "#{PRIVILEGE_URL}/#{id}"
          new(parsed.transform_keys(&:to_sym))
        end
      end

      # this is private method
      private

      def update(**payload)
        perform_post_and_parse EXCEPTION, "#{PRIVILEGE_URL}/#{id}", payload.to_json
      end
    end
  end
end
