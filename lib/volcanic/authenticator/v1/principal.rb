# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle principal api
    # method => :create, :all, :find_by_id, :update, :delete
    # attr => :name, :dataset_id, :id
    class Principal
      # Principal end-point
      PRINCIPAL_URL = 'api/v1/principals'

      attr_reader :name, :dataset_id, :id

      def initialize(name = nil, dataset_id = nil, id = nil)
        @name = name
        @dataset_id = dataset_id
        @id = id
      end

      class << self
        include Request
        include Error
        #
        # to create a new Principal.
        #
        # eg.
        #  principal = Volcanic::Authenticator::V1::Principal.create(principal_name, dataset_id)
        #  principal.name # => 'principal-a'
        #  principal.dataset_id # => 1
        #  principal.id # => 1
        #
        def create(name, dataset_id)
          payload = { name: name, dataset_id: dataset_id }.to_json
          res = perform_post_request PRINCIPAL_URL, payload
          raise_exception_principal res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['dataset_id'], parser['id'])
        end

        #
        # to receive all principals.
        #
        #  eg.
        #   principals = Principal.all
        #   principals[0].name # =>
        #   principal.name # => 'principal-a'
        #   principal.dataset_id # => 1
        #   ...
        #
        # note: authenticator service need to implement sort or pagination.
        #
        def all
          res = perform_get_request "#{PRINCIPAL_URL}/all"
          raise_exception_principal res unless res.success?
          parser = JSON.parse(res.body)['response']
          parser.map do |p|
            new(p['name'], p['dataset_id'], p['id'])
          end
        end

        #
        # to find principal by given id
        #
        # eg.
        #   principal = Principal.find_by_id(principal_id)
        #   principal.name # => 'principal-a'
        #   principal.dataset_id # => 1
        #   ...
        #
        def find_by_id(id)
          res = perform_get_request "#{PRINCIPAL_URL}/#{id}"
          raise_exception_principal res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['dataset_id'], parser['id'])
        end

        #
        # to update a principal.
        #  eg.
        #  # attributes need to be in hash value
        #  attributes = { name: 'newPrincipalName' }
        #  Principal.update(principal_id, attributes)
        #
        def update(id, attr)
          raise PrincipalError, 'Attributes must be a hash type' unless attr.is_a?(Hash)

          payload = attr.to_json
          res = perform_post_request "#{PRINCIPAL_URL}/#{id}", payload
          raise_exception_principal res unless res.success?
        end

        #
        # to delete a principal
        #  eg.
        #  Principal.delete(principal_id)
        #
        def delete(id)
          res = perform_delete_request "#{PRINCIPAL_URL}/#{id}"
          raise_exception_principal res unless res.success?
        end
      end
    end
  end
end
