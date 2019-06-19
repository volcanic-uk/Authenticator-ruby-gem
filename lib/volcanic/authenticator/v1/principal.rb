# frozen_string_literal: true

require_relative 'error'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle principal api
    # method => :create, :retrieve, :update, :delete
    # attr => :name, :dataset_id, :id
    class Principal
      attr_reader :name, :dataset_id, :id

      def initialize(name = nil, dataset_id = nil, id = nil)
        @name = name
        @dataset_id = dataset_id
        @id = id
      end

      class << self
        include Request
        include Error

        ##
        # Create new principal.
        # name and dataset id are required on creating principal
        #
        # eg.
        #  principal = Volcanic::Authenticator::V1::Principal.create('principal-a',1)
        #  principal.name # => 'principal-a'
        #  principal.dataset_id # => 1
        #  principal.id # => 1
        #
        def create(name, dataset_id)
          payload = { name: name,
                      dataset_id: dataset_id }.to_json
          res = perform_post_request PRINCIPAL_URL, payload
          raise_exception_principal res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['dataset_id'], parser['id'])
        end

        ##
        # Retrieve/get principal
        # 1) retrieve all
        #  eg.
        #   Volcanic::Authenticator::V1::Principal.retrieve
        #   # => return of array principal object
        #
        # 2) retrieve by id
        #  eg.
        #   principal = Volcanic::Authenticator::V1::Principal.retrieve(1)
        #   principal.name # => 'any_name'
        #   principal.id # => '<GENERATED_ID'
        #   principal.dataset_id # => 1
        #
        def retrieve(id = 'all')
          res = perform_get_request "#{PRINCIPAL_URL}/#{id}"
          raise_exception_principal res unless res.success?

          parser = JSON.parse(res.body)['response']

          # convert json to array of principal object
          if id == 'all'
            return parser.map do |p|
              Principal.new(p['name'], p['dataset_id'], p['id'])
            end
          end

          # return principal object
          new(parser['name'], parser['dataset_id'], parser['id'])
        end

        ##
        # Update principal
        #  Eg.
        #  attr = { name: 'newPrincipalName' }
        #  Principal.update(1, attr)
        #
        def update(id, attributes)
          unless attributes.is_a?(Hash)
            raise PrincipalError, 'Attributes must be a hash type'
          end

          payload = attributes.to_json
          res = perform_post_request "#{PRINCIPAL_UPDATE_URL}/#{id}", payload
          raise_exception_principal res unless res.success?
        end

        ##
        # Delete principal
        #  Eg.
        #  Principal.delete(1)
        #
        def delete(id)
          res = perform_post_request "#{PRINCIPAL_DELETE_URL}/#{id}"
          raise_exception_principal res unless res.success?
        end
      end
    end
  end
end
