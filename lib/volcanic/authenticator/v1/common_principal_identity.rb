# frozen_string_literal: true

require_relative 'common'
require_relative 'role'
require_relative 'privilege'

module Volcanic::Authenticator
  module V1
    # This class only support for Principal and Identity class.
    # Both of this class contains a similar method which is updating
    # privilege and role ids. This class inherit with Common.rb, so it
    # also support all the common methods.
    class CommonPrincipalIdentity < Common
      attr_reader :active

      # if deleted, this will return false
      alias active? active

      # these methods are required to be define at child classes.
      def role_ids
        raise_not_implemented_error 'role_ids'
      end

      def privilege_ids
        raise_not_implemented_error 'privilege_ids'
      end

      def role_ids=(ids)
        raise_type_error(:role_ids, 'Array', ids) unless ids.is_a? Array
        @role_ids = ids
        @role = nil
      end

      def privilege_ids=(ids)
        raise_type_error(:privilege_ids, 'Array', ids) unless ids.is_a? Array
        @privilege_ids = ids
        @privilege = nil
      end

      # updating role ids
      #  eg.
      #     obj = Object.find_by_id(1)
      #     obj.role_ids   #=> [1, 2]
      #     obj.update_role_ids(3, '4', [5], nil)
      #     obj.role_ids   #=> [3, 4, 5]
      def update_role_ids(*ids)
        perform_request "/#{id}/roles", roles: ids.flatten.compact
        self.role_ids = ids.flatten.compact.map!(&:to_i)
      end

      # updating privilege ids
      #  eg.
      #     obj = Object.find_by_id(1)
      #     obj.privilege_ids   #=> [1, 2]
      #     obj.update_privilege_ids(3, '4', [5], nil)
      #     obj.privilege_ids   #=> [3, 4, 5]
      def update_privilege_ids(*ids)
        perform_request "/#{id}/privileges", privileges: ids.flatten.compact
        self.privilege_ids = ids.flatten.compact.map!(&:to_i)
      end

      def activate!
        perform_request("/#{id}/activate")
      end

      # deactivate identity.
      def deactivate!
        perform_request("/#{id}/deactivate")
      end

      def roles
        @roles ||= begin
          res = perform_get_and_parse(self.class.exception, "#{self.class.path}/#{id}/roles")
          self.role_ids = []
          res.map do |role|
            obj = role.transform_keys(&:to_sym)
            role_ids << obj[:id]
            Role.new(**obj)
          end
        end
      end

      def privileges
        @privileges ||= begin
          res = perform_get_and_parse(self.class.exception, "#{self.class.path}/#{id}/privileges")
          self.privilege_ids = []
          res.map do |privilege|
            obj = privilege.transform_keys(&:to_sym)
            privilege_ids << privilege[:id]
            Privilege.new(**obj)
          end
        end
      end

      # by default principal and identity will fetch roles and privileges,
      # if wanted to disable this just pass nil for +include+ object
      def self.find_by_id(id, **opts)
        params = { include: 'roles,privileges' }
        super id, **params.update(**opts)
      end

      private

      def perform_request(endpoint, **payloads)
        path = [self.class.path, endpoint].join
        perform_post_and_parse self.class.exception, path, payloads.to_json
      end
    end
  end
end
