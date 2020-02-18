# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Handle service api
    class Service < Common
      attr_accessor :name
      attr_reader :id, :subject_id, :updated_at, :created_at

      def self.path
        'api/v1/services'
      end

      def self.exception
        ServiceError
      end

      # initialize new service
      def initialize(id:, **opts)
        @id = id
        %i[name subject_id created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
      end

      # service.name = 'update_name'
      # service.save
      def save
        super({ name: name })
      end

      # service = Service.create('vault')
      # service.name # => vault
      # service.id # => 1
      # ...
      def self.create(name)
        super({ name: name })
      end
    end
  end
end
