# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Handle permission api
    class Permission < Common
      PATH = 'api/v1/permissions'
      EXCEPTION = :raise_exception_permission

      attr_accessor :name, :description
      attr_reader :id, :active, :subject_id, :service_id, :created_at, :updated_at
      #
      # initialize permission
      def initialize(id:, **opts)
        @id = id
        %i[name description subject_id service_id active created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
      end

      alias active? active

      def save
        payload = { name: name, description: description }
        super payload
      end

      def self.create(name, service_id, description = nil)
        payload = { name: name,
                    description: description,
                    service_id: service_id }
        super payload
      end

      def self.path
        PATH
      end
    end
  end
end
