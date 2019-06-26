# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    #
    # Privileges api
    # method => :create, :all, find_by_id :update, :delete
    # attr => :scope, :id, :permission_id, :group_id, :allow
    class Privilege
      PRIVILEGE_URL = 'api/v1/privilege'
      PRIVILEGES_URL = 'api/v1/privileges'

      attr_reader :scope, :id, :permission_id, :group_id, :allow
      ##
      # initialize new privilege
      def initialize(scope = nil, id = nil, permission_id = nil, group_id = nil, allow = nil)
        @scope = scope
        @id = id
        @permission_id = permission_id
        @group_id = group_id
        @allow = allow == 1
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
        def create(scope, permission_id = nil, group_id = nil)
          payload = { scope: scope,
                      permission_id: permission_id,
                      group_id: group_id }.to_json
          res = perform_post_request PRIVILEGE_URL, payload
          raise_exception_privilege res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['scope'], parser['id'], parser['permission_id'], parser['group_id'])
        end

        #
        # to receive an array of privileges
        #
        # eg.
        #   privileges = privilege.all
        #   privileges[0].name # => 'privilege-a'
        #   privileges[0].id # => '<privilege_ID>'
        #   ....
        #
        def all
          res = perform_get_request PRIVILEGES_URL
          raise_exception_privilege res unless res.success?
          parser = JSON.parse(res.body)['response']
          parser.map do |privilege|
            new(privilege['scope'],
                privilege['id'],
                privilege['permission_id'],
                privilege['group_id'],
                privilege['allow'])
          end
        end

        #
        # to find by given id
        #
        # eg.
        #   privilege = privilege.find_by_id(privilege_id)
        #   privilege.name # => 'privilege-a'
        #   privilege.id # => '<privilege_ID>'
        #   ....
        #
        def find_by_id(id)
          res = perform_get_request "#{PRIVILEGE_URL}/#{id}"
          raise_exception_privilege res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['scope'],
              parser['id'],
              parser['permission_id'],
              parser['group_id'],
              parser['allow'])
        end

        ##
        # Update privilege
        #  Eg.
        #  attributes = { scope: 'this is new scope', permission_id: 10, group_id: 2 }
        #  Privilege.update(privilege_id, attributes)
        #
        # attributes => :scope, :group_id, :permission_id
        #
        def update(id, attributes)
          raise PrivilegeError, 'Attributes must be a hash type' unless attributes.is_a?(Hash)

          payload = attributes.to_json
          res = perform_post_request "#{PRIVILEGE_URL}/#{id}", payload
          raise_exception_privilege res unless res.success?
        end

        ##
        # Delete privilege
        #  Eg.
        #  privilege.delete(1)
        #
        def delete(id)
          res = perform_delete_request "#{PRIVILEGE_URL}/#{id}"
          raise_exception_privilege res unless res.success?
        end
      end
    end
  end
end
