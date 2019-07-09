# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Role API
    class Role < Common
      attr_accessor :name
      attr_reader :id, :parent_id, :created_at, :updated_at

      def self.path
        'api/v1/roles'
      end

      def self.exception
        RoleError
      end

      # initialize new role
      def initialize(id:, **opts)
        @id = id
        %i[name parent_id created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
      end

      def save
        super(name: name)
      end

      class << self
        def create(name, privilege_ids: [], parent_id: nil)
          super({ name: name, privileges: privilege_ids, parent_role_id: parent_id })
        end
      end
    end
  end
end
