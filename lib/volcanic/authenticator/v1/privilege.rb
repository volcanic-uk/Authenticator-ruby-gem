# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Subject api
    class Privilege < Common
      class << self
        def path
          'api/v1/privileges'
        end

        def exception
          PrivilegeError
        end
      end

      def initialize(scope:, permission_id: nil, group_id: nil, allow:, **args)
        @id = args.fetch(:id, nil)
        @scope = scope
        @permission_id = permission_id
        @group_id = group_id
        @allow = allow
      end

      # Compare provided VRN with the scope we have
      # Returns
      # => boolean
      def in_scope?(vrn)
        Scope.new(scope).include?(vrn)
      end

      def permissions
        @permissions ||= permission_ids.map { |permission_id| Permission.find_by_id(permission_id) }
      end

      attr_accessor :id, :scope, :permission_id, :group_id, :allow, :permission

      private

      def permission_ids
        @permission_ids ||= [permission_id, PermissionGroup.find_by_id(group_id).permission_ids].flatten.compact
      end
    end
  end
end
