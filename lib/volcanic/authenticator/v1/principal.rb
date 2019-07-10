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
      include Request
      include Error

      # Principal end-point
      PRINCIPAL_URL = 'api/v1/principals'
      EXCEPTION = :raise_exception_principal

      attr_reader :id
      attr_accessor :name, :dataset_id

      def initialize(id:, **opts)
        @id = id
        @name = opts[:name]
        @dataset_id = opts[:dataset_id]
        @active = opts[:active]
      end

      #
      # check activation
      # eg .
      #
      def active?
        @active == 1
      end

      #
      # to update a principal.
      #  eg.
      #
      def save
        payload = { name: name, dataset_id: dataset_id }.to_json
        perform_post_and_parse EXCEPTION, "#{PRINCIPAL_URL}/#{id}", payload
      end

      #
      # to delete a principal
      #  eg.
      #  Principal.new(id: 1).delete
      #
      def delete
        perform_delete_and_parse EXCEPTION, "#{PRINCIPAL_URL}/#{id}"
      end

      class << self
        include Request
        include Error
        #
        # to create a new Principal.
        #
        # eg.
        #  principal = Volcanic::Authenticator::V1::Principal.create(principal_name, dataset_id, roles, privileges)
        #  principal.name # => 'principal-a'
        #  principal.dataset_id # => 1
        #  principal.id # => 1
        #
        def create(name, dataset_id, roles = [], privileges = [])
          payload = { name: name,
                      dataset_id: dataset_id,
                      roles: roles,
                      privileges: privileges }.to_json
          parsed = perform_post_and_parse EXCEPTION, PRINCIPAL_URL, payload
          new(parsed.transform_keys(&:to_sym))
        end

        #
        # to find principals.
        #
        def find(key_name: '', page: 1, page_size: 10)
          params = %W[query=#{key_name} page=#{page} page_size=#{page_size}]
          url = "#{PRINCIPAL_URL}?#{params.join('&')}"
          parsed = perform_get_and_parse EXCEPTION, url
          parsed['data'].map do |data|
            new(data.transform_keys(&:to_sym))
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
          raise ArgumentError, 'id is empty or nil' if id.nil? || id == ''

          parsed = perform_get_and_parse EXCEPTION, "#{PRINCIPAL_URL}/#{id}"
          new(parsed.transform_keys(&:to_sym))
        end
      end
    end
  end
end
