# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle service api
    # class method => :create, :all, :find_by_id
    # class instance =>  :name, :id :save, :delete, :active?
    class Service
      include Request
      include Error
      # end-point
      SERVICE_URL = 'api/v1/services'
      EXCEPTION = :raise_exception_service

      attr_accessor :name, :id, :subject_id
      #
      # initialize new service
      def initialize(id, opt = {})
        @id = id
        @name = opt['name']
        @active = opt['active']
        @subject_id = opt['subject_id']
      end

      #
      # to check active service
      #
      # eg.
      #   service = Service.find_by_id(1)
      #   service.active? #=> true
      #
      def active?
        @active == 1
      end

      #
      # to update a service.
      #
      # eg.
      #   service = Service.find_by_id(1)
      #   service.name = 'new-service-name'
      #   service.save
      #
      def save
        payload = { name: name }.to_json
        perform_post_and_parse EXCEPTION, "#{SERVICE_URL}/#{id}", payload
      end

      #
      # to delete service
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
        perform_delete_and_parse EXCEPTION, "#{SERVICE_URL}/#{id}"
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
          parsed = perform_post_and_parse EXCEPTION, SERVICE_URL, payload
          new(parsed['id'], parsed)
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
        def all(page: 1, page_size: 10, query: '')
          url = "#{SERVICE_URL}?page=#{page}&page_size=#{page_size}&query=#{query}"
          parsed = perform_get_and_parse EXCEPTION, url
          parsed['data'].map do |data|
            new(data['id'], data)
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
          raise ArgumentError, 'argument is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse EXCEPTION, "#{SERVICE_URL}/#{id}"
          new(parsed['id'], parsed)
        end
      end
    end
  end
end
