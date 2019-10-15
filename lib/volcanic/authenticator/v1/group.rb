# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Group API
    class Group < Common
      PATH = 'api/v1/groups'
      EXCEPTION = :raise_exception_group

      attr_accessor :id, :name, :description, :permissions
      attr_reader :created_at, :updated_at, :active

      # initialize new group
      def initialize(id:, **opts)
        @id = id
        %i[name description active created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
      end

      # updating
      def save
        payload = { name: name, description: description }
        super payload
      end

      alias active? active

      class << self
        # creating new
        def create(name, description = nil, *permissions)
          payload = { name: name,
                      description: description,
                      permissions: permissions.flatten.compact }
          group = super payload
          group.permissions = permissions.flatten.compact
          group
        end

        def path
          PATH
        end

        alias find_by_name find_by_id
      end
    end
  end
end
