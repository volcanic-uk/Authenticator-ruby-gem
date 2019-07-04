# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'

module Volcanic::Authenticator
  module V1
    ##
    # Handle principal api
    # method => :create, :find, :find_by_id, :save, :delete
    # attr => :name, :dataset_id, :id
    class Principal
      include Request
      include Error
      # Principal end-point
      PRINCIPAL_URL = 'api/v1/principals'
      EXCEPTION = :raise_exception_principal

      attr_reader :id, :login_attempts
      attr_accessor :name, :dataset_id

      def initialize(**opt)
        @id = opt[:id]
        @name = opt[:name]
        @dataset_id = opt[:dataset_id]
        @login_attempts = opt[:login_attempts]
      end

      #
      # to update a principal.
      #  eg.
      #   principal = Principal.find_by_id(1)
      #   principal.name = 'new principal name'
      #   principal.dataset_id = 10
      #   principal.save
      #
      def save
        payload = { name: name, dataset_id: dataset_id }.to_json
        perform_post_and_parse EXCEPTION, "#{PRINCIPAL_URL}/#{id}", payload
      end

      #
      # to delete a principal
      #  eg.
      #  principal = Principal.find_by_id(1)
      #  principal.delete
      #
      # OR
      #
      #   Principal.new(id: 1).delete
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
        #  principal = Volcanic::Authenticator::V1::Principal.create(principal_name, dataset_id)
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
        # to find principal
        #
        # eg.
        #  1) find principal by id
        #   principal = Principal.find(id: 1)
        #
        #  NOTE: all below cases return an array of principal object
        #
        #  1) by default
        #   principal = Principal.find
        #   principal.size # => 10
        #
        #  2) find by key name
        #   principal = Principal.find(key_name: 'volcanic')
        #
        #  3) find by key name and set page size
        #   principal = Principal.find(key_name: 'volcanic', page_size: 5)
        #   principal.size # => 5
        #
        #  4) find by key name, set page size and set page
        #   principal = Principal.find(key_name: 'volcanic' page: 2, page_size: 5)
        #   principal.size # => 5
        #   principal[0].id # => 6
        #
        #  5) find by dataset_id
        #   principal = Principal.find(dataset_id: 10)
        #   principal[0].dataset_id # => 10
        #
        def find(id: nil, key_name: '', dataset_id: '', page: 1, page_size: 10)
          return find_by_id(id) unless id.nil?

          params = %W[query=#{key_name} dataset_id=#{dataset_id} page=#{page} page_size=#{page_size}]
          url = "#{PRINCIPAL_URL}?#{params.join('&')}"
          parsed = perform_get_and_parse EXCEPTION, url
          parsed['data'].map do |data|
            new(data.transform_keys(&:to_sym))
          end
        end

        #
        # find principal by specific id
        # eg.
        #   principal = Principal.find_by_id(1)
        #   principal.name # => 'principal-a'
        #   principal.dataset_id # => 10
        #   ...
        #
        def find_by_id(id)
          url = "#{PRINCIPAL_URL}/#{id}"
          parsed = perform_get_and_parse EXCEPTION, url
          new(parsed.transform_keys(&:to_sym))
        end
      end
    end
  end
end
