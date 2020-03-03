# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Subject api
    class Subject < Common
      class << self
        def path
          'api/v1/subject'
        end

        def exception
          SubjectError
        end

        # Gets a list of permissions back from the AuthService
        # Create Permission objects, in memory
        # Create Privilege objects, referencing the Permission object
        # Return an array of Privilege objects
        # Filtering by service, a single hash is returned.
        def privileges_for(subject, service)
          response = perform_get_and_parse(
            exception,
            "#{path}/privileges?filter[subject]=#{subject}&filter[service]=#{service}"
          )
          return [] if response.blank?

          @privileges_for ||= permissions_for(subject, service).map(&:privileges).flatten
        end

        def permissions_for(subject, service)
          response = perform_get_and_parse(
            exception,
            "#{path}/privileges?filter[subject]=#{subject}&filter[service]=#{service}"
          )
          return [] if response.blank?

          @permissions_for ||= response['permissions'].map do |permission|
            build_permission(permission)
          end
        end

        private

        def build_permission(permission)
          Permission.new(name: permission.fetch('name'), active: true).tap do |perm|
            perm.id = permission.fetch('id')
            perm.privilege_ids = permission.fetch('privileges', []).map { |p| p['id'] }
            perm.privileges = permission.fetch('privileges', []).map do |privilege|
              build_privilege(perm, privilege)
            end
          end
        end

        def build_privilege(permission, privilege)
          Privilege.new(scope: privilege.fetch('scope'), allow: privilege.fetch('allow')).tap do |priv|
            priv.id = privilege.fetch('id')
            priv.permission_id = permission.id
            priv.permission = permission
          end
        end
      end
    end
  end
end
