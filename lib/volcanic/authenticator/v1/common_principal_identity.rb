# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # This class only support for Principal and Identity class.
    # Both of this class contains a similar method which is updating
    # privilege and role ids. This class inherit with Common.rb, so it
    # also support all the common methods.
    class CommonPrincipalIdentity < Common
      # these methods are required to be define at child classes.
      def role_ids
        raise_not_implemented 'role_ids'
      end

      def privilege_ids
        raise_not_implemented 'privilege_ids'
      end

      # updating role ids
      #  eg.
      #   obj = Object.find_by_id(1)
      #   obj.role_ids = [1, 2]
      #   obj.update_role_ids(3, '4', [5], nil)
      #   obj.role_ids = [3, 4, 5]
      def update_role_ids(*ids)
        payload = { roles: ids.flatten.compact }
        path = [self.class.path, "/#{id}/roles"].join
        request_to_update path, payload
        self.role_ids = ids.flatten.compact.map!(&:to_i)
      end

      # updating privilege ids
      #  eg.
      #   obj = Object.find_by_id(1)
      #   obj.privilege_ids = [1, 2]
      #   obj.update_privilege_ids(3, '4', [5], nil)
      #   obj.privilege_ids = [3, 4, 5]
      def update_privilege_ids(*ids)
        payload = { privileges: ids.flatten.compact }
        path = [self.class.path, "/#{id}/privileges"].join
        request_to_update path, payload
        self.privilege_ids = ids.flatten.compact.map!(&:to_i)
      end

      private

      def request_to_update(path, payload)
        perform_post_and_parse self.class.exception, path, payload.to_json
      end

      def raise_not_implemented(key)
        raise NotImplementedError, "#{key} must be defined by child classes"
      end
    end
  end
end
