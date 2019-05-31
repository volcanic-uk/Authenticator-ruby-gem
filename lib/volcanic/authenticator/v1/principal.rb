require 'httparty'
require_relative 'header'
require_relative 'token_key'
require_relative 'error_response'

module Volcanic::Authenticator
  module V1
    ##
    # This is Principal Api class
    class Principal
      extend Volcanic::Authenticator::V1::Header
      extend Volcanic::Authenticator::V1::ErrorResponse

      # URLS
      PRINCIPAL = 'api/v1/principal'
      PRINCIPAL_DELETE = 'api/v1/principal/delete'
      PRINCIPAL_UPDATE = 'api/v1/principal/update'

      attr_reader :name, :dataset_id, :id, :last_active_date, :active

      def initialize(name = nil, dataset_id = nil, id = nil, active = nil, last_active = nil)
        @name = name
        @dataset_id = dataset_id
        @id = id
        @last_active_date = last_active
        @active = active
      end

      class << self
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

        def delete(id)
          res = perform_post_request "#{PRINCIPAL_DELETE}/#{id}"
          raise_exception_principal res unless res.success?
        end

        def update(id, attributes)
          payload = attributes.to_json
          res = perform_post_request "#{PRINCIPAL_UPDATE}/#{id}", payload
          raise_exception_principal res unless res.success?
        end

        private

        def perform_post_request(end_point, body = nil)
          url = Volcanic::Authenticator.config.auth_url
          HTTParty.post "#{url}/#{end_point}", body: body, headers: bearer_header(TokenKey.fetch_and_request_app_token)
        end

        def perform_get_request(end_point)
          url = Volcanic::Authenticator.config.auth_url
          HTTParty.get "#{url}/#{end_point}", headers: bearer_header(TokenKey.fetch_and_request_app_token)
        end
      end
    end
  end
end
