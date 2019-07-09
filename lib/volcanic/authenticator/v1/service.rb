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

      attr_accessor :name, :id
      attr_reader :subject_id
      #
      # initialize new service
      def initialize(id:, **opt)
        @id = id
        @name = opt[:name]
        @subject_id = opt[:subject_id]
        @active = opt[:active]
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
          new(parsed.transform_keys!(&:to_sym))
        end

        #
        # to request an array of services.
        #
        # eg.
        #   services = Service.find
        #   services[1].name # => 'service-a'
        #   services[1].id # => 1
        #   ...
        #
        def find(key_name: '', page: 1, page_size: 10)
          params = %W[page=#{page} page_size=#{page_size} query=#{key_name}]
          url = "#{SERVICE_URL}?#{params.join('&')}"
          parsed = perform_get_and_parse EXCEPTION, url
          parsed['data'].map do |data|
            new(data.transform_keys!(&:to_sym))
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
          new(parsed.transform_keys!(&:to_sym))
        end
      end
    end
  end
end
