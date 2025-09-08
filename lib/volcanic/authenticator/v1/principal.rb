# frozen_string_literal: true

require_relative 'common_principal_identity'

module Volcanic::Authenticator
  module V1
    # Principal api
    # TODO: principal_spec is missing!
    class Principal < CommonPrincipalIdentity
      attr_reader :created_at, :updated_at, :privilege_ids, :role_ids
      attr_accessor :id, :secure_id, :name, :dataset_id, :stack_id

      # Principal end-point
      def self.path
        'api/v1/principals'
      end

      # Exception method for handling error. Please find this at helper/error.rb
      def self.exception
        PrincipalError
      end

      def initialize(**opts)
        %i[id secure_id name dataset_id role_ids privilege_ids active created_at updated_at stack_id].each do |key|
          instance_variable_set("@#{key}", opts[key])
        end
      end

      # to update a principal.
      #  eg.
      #   principal = Principal.find_by_id(1)
      #   principal.name = 'update_name'
      #   principal.save
      #
      def save
        payload = { name: name, privileges: privilege_ids, roles: role_ids }
        super(**payload)
      end

      # to create a new Principal.
      #
      # eg.
      #  role_ids = [1, 3]
      #  privilege_ids = [1, 5]
      #  principal = Principal.create(principal_name, dataset_id, role_ids, privilege_ids)
      #  principal.name # => 'principal-a'
      #  principal.dataset_id # => 1
      #  principal.id # => 1
      #
      def self.create(name, dataset_id, role_ids = [], privilege_ids = [])
        payload = { name: name,
                    dataset_id: dataset_id,
                    roles: role_ids,
                    privileges: privilege_ids }
        principal = super payload
        # TODO: remove this when auth returning the correct id (secure_id)
        principal.id = principal.secure_id unless principal.secure_id.nil?
        # set information that does not provide by the api response
        principal.role_ids = role_ids
        principal.privilege_ids = privilege_ids
        principal
      end
    end
  end
end
