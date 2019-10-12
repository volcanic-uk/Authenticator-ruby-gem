# frozen_string_literal: true

require_relative 'common'

module Volcanic::Authenticator
  module V1
    # Principal api
    class Principal < Common

      # Principal end-point
      PATH = 'api/v1/principals'
      EXCEPTION = :raise_exception_principal

      attr_reader :id, :created_at, :updated_at, :active
      attr_accessor :name, :dataset_id

      def initialize(id:, **opts)
        @id = id
        %i[name dataset_id active created_at updated_at].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
      end

      def active?
        active
      end

      # to update a principal.
      #  eg.
      #
      def save
        payload = { name: name, dataset_id: dataset_id }
        super payload
      end

      # to create a new Principal.
      #
      # eg.
      #  roles = [1, 3]
      #  privileges = [1, 5]
      #  principal = Principal.create(principal_name, dataset_id, roles, privileges)
      #  principal.name # => 'principal-a'
      #  principal.dataset_id # => 1
      #  principal.id # => 1
      #  ...
      #
      def self.create(name, dataset_id, roles = [], privileges = [])
        payload = { name: name,
                    dataset_id: dataset_id,
                    roles: roles,
                    privileges: privileges }
        super payload
      end

      def self.path
        PATH
      end
    end
  end
end
