require_relative 'error'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle principal api
    # method => :create, :retrieve, :update, :delete
    # attr => :name, :dataset_id, :id, :last_active_date, :active
    class Principal
      attr_reader :name, :dataset_id, :id, :last_active_date, :active

      def initialize(name = nil, dataset_id = nil, id = nil, active = nil, last_active = nil)
        @name = name
        @dataset_id = dataset_id
        @id = id
        @last_active_date = last_active
        @active = active
      end

      class << self
        include Request
        include Error

        ##
        # Create new principal.
        # name and dataset id are required on creating principal
        #
        # eg.
        #  principal = Volcanic::Authenticator::V1::Principal.create('any_name', 1)
        #  principal.name # => 'any_name'
        #  principal.id # => '<GENERATED_ID'
        #  principal.dataset_id # => 1
        #
        def create(name, dataset_id)
          payload = { name: name,
                      dataset_id: dataset_id }.to_json
          res = perform_post_request PRINCIPAL, payload
          raise_exception_principal res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['dataset_id'], parser['id'])
        end

        ##
        # Retrieve/get principal
        # 1) retrieve all
        #  eg.
        #   Volcanic::Authenticator::V1::Principal.retrieve
        #   # =>
        #         [
        #             {
        #                 "id": 1,
        #                 "name": "volcanic-principal",
        #                 "dataset_id": nil,
        #                 "last_active_date": nil,
        #                 "active": 1,
        #                 "created_at": "2019-05-27T04:56:41.000Z",
        #                 "updated_at": "2019-05-27T04:56:41.000Z"
        #             }
        #         ]
        #
        # 2) retrieve by id
        #  eg.
        #   principal = Volcanic::Authenticator::V1::Principal.retrieve(1)
        #   principal.name # => 'any_name'
        #   principal.id # => '<GENERATED_ID'
        #   principal.dataset_id # => 1
        #   principal.active # => 1
        #   principal.last_active_date # => "2019-05-28T03:14:11.719Z"
        #
        def retrieve(id = 'all')
          res = perform_get_request "#{PRINCIPAL}/#{id}"
          raise_exception_principal res unless res.success?
          parser = JSON.parse(res.body)['response']
          return parser if id == 'all'

          new(parser['name'],
              parser['dataset_id'],
              parser['id'],
              parser['active'],
              parser['last_active_date'])
        end

        ##
        # Update principal
        #  Eg.
        #  attr = { name: 'newPrincipalName' }
        #  Principal.update(1, attr)
        #
        def update(id, attributes)
          raise PrincipalError, 'Attributes must be a hash type' unless attributes.is_a?(Hash)

          payload = attributes.to_json
          res = perform_post_request "#{PRINCIPAL_UPDATE}/#{id}", payload
          raise_exception_principal res unless res.success?
        end

        ##
        # Delete principal
        #  Eg.
        #  Principal.delete(1)
        #
        def delete(id)
          res = perform_post_request "#{PRINCIPAL_DELETE}/#{id}"
          raise_exception_principal res unless res.success?
        end
      end
    end
  end
end
