# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Subject api
    class PermissionGroup < Common
      class << self
        def path
          'api/v1/groups'
        end

        def exception
          PermissionGroupError
        end
      end

      def initialize(name:, active:, permissions: [], **args)
        super()
        @id = args.fetch(:id, nil)
        @name = name
        @active = active
        %i[description subject_id created_at updated_at].each do |arg|
          send("#{arg}=", args.fetch(arg, ''))
        end
        @permissions = permissions.map { |d| Permission.new(**d.transform_keys(&:to_sym)) }
        @dirty_permissions = []
      end

      def permission_ids
        load_permissions unless @dirty_permissions.empty?
        @permissions.map(&:id).freeze
      end

      def permission_ids=(value)
        @dirty_permissions = value
      end

      def permissions
        @permissions.dup.freeze
      end

      attr_accessor :id, :name, :description, :subject_id, :active, :created_at, :updated_at

      private

      def load_permissions
        perm_ids_to_fetch = @dirty_permissions - @permissions.map(&:id)

        # TODO: replace this logic with single query to the service for all IDs when supported
        #  - AUTH-338
        found = perm_ids_to_fetch.map { |id| find_by_id(id) }

        # remove old permissions where needed
        @permissions.delete_if { |item| @dirty_permissions.include?(item.id) }

        @permissions.concat found
        @dirty_permissions = []
      end
    end
  end
end
