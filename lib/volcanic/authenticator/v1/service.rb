# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle service api
    # class method => :create, :all, :find_by_id
    # class instance =>  :name, :id :save, :delete
    class Service
      include Request
      include Error
      # end-point
      SERVICE_URL = 'api/v1/service'
      SERVICE_UPDATE_URL = 'api/v1/service/update'

      attr_accessor :name, :id
      attr_reader :active

      #
      # initialize new service
      def initialize(id, name = nil)
        @id = id
        @name = name
      end

      #
      # to update a service. The attributes need to be in hash value.
      #
      # eg.
      #   service = Service.find_by_id(1)
      #   service.name = 'new-service-name'
      #   service.save
      #
      def save
        payload = { name: name }.to_json
        res = perform_post_request "#{SERVICE_UPDATE_URL}/#{id}", payload
        raise_exception_service res unless res.success?
      end

      #
      # to soft delete service
      #
      # eg.
      #   service = Service.find_by_id(1)
      #   service.delete
      #
      #   OR
      #
      #   Service.new(2).delete
      #
      def delete
        res = perform_delete_request "#{SERVICE_URL}/#{id}"
        raise_exception_service res unless res.success?
      end

      class << self
        include Request
        include Error
        ##
        # Create new service
        # Eg.
        #  service = Service.create('service-a')
        #  service.name # => 'service-a'
        #  service.id # => 1
        #
        def create(name)
          payload = { name: name }.to_json
          res = perform_post_request SERVICE_URL, payload
          raise_exception_service res unless res.success?
          parser = JSON.parse(res.body)['response']
          new(parser['id'], parser['name'])
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
        #   so that we dont have to receive bulk of services.
        #
        def all
          res = perform_get_request "#{SERVICE_URL}/all"
          raise_exception_service res unless res.success?
          parser = JSON.parse(res.body)['response']
          parser.map do |service|
            new(service['id'], service['name'])
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
          new(parser['id'], parser['name'])
        end
      end
    end
  end
end
