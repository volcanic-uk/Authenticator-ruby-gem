# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Handle role api
    class Role < Common
      URL = 'api/v1/roles'
      EXCEPTION = :raise_exception_role

      attr_accessor :id, :name, :service_id
      attr_reader :subject_id, :created_at, :updated_at

      undef_method :active?

      # initialize new role
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @subject_id = opt[:subject_id]
        @service_id = opt[:service_id]
        @created_at = opt[:created_at]
        @updated_at = opt[:updated_at]
      end

      def privileges=(*ids)
        @privileges = ids.flatten.compact
      end

      # to update a role.
      #
      # eg.
      #   role = Role.find_by_id(1)
      #   role.name = 'new-role-name'
      #   role.save
      #
      def save
        payload = { name: name, service_id: service_id, privileges: @privileges }
        super(payload)
      end

      # Create new role
      # Eg.
      #  role = Role.create('role-a')
      #  role.name # => 'role-a'
      #  role.id # => 1
      #
      def self.create(name, service_id, *privileges)
        payload = { name: name,
                    service_id: service_id,
                    privileges: privileges.flatten.compact }
        super(payload)
      end
    end
  end
end
