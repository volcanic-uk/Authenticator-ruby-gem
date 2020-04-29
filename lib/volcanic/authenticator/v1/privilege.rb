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
        @scope = Scope.parse(scope)
        @permission_id = permission_id
        @group_id = group_id
        @allow = allow
      end

      def <=>(other)
        if scope == other.scope
          (allow_bool <=> other.allow_bool) * -1
        else
          scope <=> other.scope
        end
      end

      # Compare provided VRN with the scope we have
      # Returns
      # => boolean
      def in_scope?(vrn)
        scope.include?(vrn)
      end

      # Without casting to an integer we get a comparison error when
      # sorting using the spaceship (<=>) operator.
      def allow_bool
        allow == true ? 1 : 0
      end

      def permissions
        @permissions ||= permission_ids.map { |permission_id| Permission.find_by_id(permission_id) }
      end

      def scope=(value)
        @scope = Scope.parse(value)
      end

      attr_accessor :id, :permission_id, :group_id, :allow, :permission
      attr_reader :scope

      def ==(other)
        %i[@id @permission_id @group_id @allow @scope].all? do |field|
          instance_variable_get(field) == other.instance_variable_get(field)
        end
      end

      private

      def permission_ids
        @permission_ids ||= [permission_id, PermissionGroup.find_by_id(group_id).permission_ids].flatten.compact
      end
    end
  end
end
