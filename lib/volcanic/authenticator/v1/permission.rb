# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Handle permission api
    class Permission < Common
      URL = 'api/v1/permissions'
      EXCEPTION = :raise_exception_permission

      attr_accessor :name, :description
      attr_reader :id, :subject_id, :service_id, :created_at, :updated_at
      #
      # initialize permission
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @description = opt[:description]
        @subject_id = opt[:subject_id]
        @service_id = opt[:service_id]
        @active = opt[:active]
        @created_at = opt[:created_at]
        @updated_at = opt[:updated_at]
      end

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
    end
  end
end
