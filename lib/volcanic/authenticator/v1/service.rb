require_relative 'error'
require_relative 'request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle service api
    # method => :create, :retrieve, :update, :delete
    # attr => :name, :id, :active, :created_by
    class Service
      # end-point
      SERVICE_URL = 'api/v1/service'
      SERVICE_UPDATE_URL = 'api/v1/service/update'

      attr_reader :name, :id, :active, :created_by
      ##
      # initialize new service
      # attr => :name, :id, :active, :created_by
      def initialize(name = nil, id = nil, active = false, created_by = nil)
        @name = name
        @id = id
        @active = active == '1' ? true : false
        @created_by = created_by
      end

      class << self
        include Request
        include Error
        ##
        # Create new service
        # Eg.
        #  service = service.create('service-a')
        #  service.name # => 'service-a'
        #  service.id # => '<SERVICE_ID>'
        #
        def create(name)
          payload = { name: name }.to_json
          res = perform_post_request SERVICE_URL, payload
          raise_exception_service res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['name'], parser['id'])
        end
        #
        # to request an array of services.
        #
        # eg.
        #   services = Service.all
        #   services[1].name # => 'service-a'
        #   services[1].id # => 1
        #   ...
        #
        #  note: authenticator service need to implement sort or pagination,
        #   so that we dont to receive bulk of services.
        #
        def all(sort = 10)
          res = perform_get_request "#{SERVICE_URL}/all"
          raise_exception_service res unless res.success?
          parser = JSON.parse(res.body)['response']
          parser.map do |service|
            new(service['name'], service['id'], service['active'], service['created_by'])
          end
        end
        #
        # to request a service by given id.
        #
        # eg.
        #   service = Service.find_by_id(service_id)
        #   service.name # => 'service-a'
        #   service.id # => 1
        #   ...
        #
        def find_by_id(id)
          res = perform_get_request "#{SERVICE_URL}/#{id}"
          raise_exception_service res unless res.success?
          parser = JSON.parse(res.body)['response']
          # return service object
          new(parser['name'], parser['id'], parser['active'], parser['created_by'])
        end
        #
        # to update a service. The attributes need to be in hash value.
        #
        # eg.
        #   attributes = { name: 'service-b' }
        #   Service.update(service_id, attributes)
        #
        # available attribute to update
        # :name
        #
        def update(id, attributes)
          raise ServiceError, 'Attributes must be a hash type' unless attributes.is_a?(Hash)

          payload = attributes.to_json
          res = perform_post_request "#{SERVICE_UPDATE_URL}/#{id}", payload
          raise_exception_service res unless res.success?
        end
        #
        # to soft delete service
        #
        # eg.
        #  Service.delete(service_id)
        #
        def delete(id)
          res = perform_delete_request "#{SERVICE_URL}/#{id}"
          raise_exception_service res unless res.success?
        end
      end
    end
  end
end
