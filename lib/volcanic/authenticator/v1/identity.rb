# frozen_string_literal: true

require_relative 'helper/error'
require_relative 'helper/request'
require_relative 'base'
require_relative 'token'

module Volcanic::Authenticator
  module V1
    #
    # Handle identity api
    # class method => :register, :deactivate
    # class instance => :id, :name, :secret, :principal_id, :privilege_ids, :role_ids :token
    class Identity < Base
      include Request
      include Error

      # end-point
      IDENTITY_CREATE_URL = 'api/v1/identity'
      IDENTITY_DELETE_URL = 'api/v1/identity/deactivate'

      attr_reader :id, :name, :secret, :principal_id
      # id = nil, name = nil, secret = nil, principal_id = nil
      def initialize(**opt)
        @id = opt[:id]
        @name = opt[:name]
        @secret = opt[:secret]
        @principal_id = opt[:principal_id]
      end

      #
      # Typically this generate a token
      #
      # eg.
      #  token = Identity.create(name, principal_id).token
      #  # => return a token
      #
      # Note:
      # Be careful when using this. Basically this is creating new identity
      # and generate a new token.
      # If you just want to generate a token please use this method instead:
      #
      #   Token.create(name, secret).token_key
      #
      def token
        Token.create(name, secret).token_key
      end

      #
      # Deactivate an identity and blacklist all associate tokens.
      # eg.
      #   Identity.new(id).deactivate
      #
      def deactivate
        res = perform_post_request("#{IDENTITY_DELETE_URL}/#{id}", nil)
        raise_exception_identity(res) unless res.success?
      end

      class << self
        include Request
        include Error
        #
        # to register an identity.
        # required a name and principal id (prerequisite to create a principal).
        #
        # eg.
        #   identity = Identity.register(name, principal_id)
        #   identity.name # => 'name'
        #   identity.secret # => <GENERATED_SECRET> # auto-generated if not given
        #   identity.principal_id # => 1
        #   identity.id # => 1
        #   identity.token # => <GENERATED_TOKEN>
        #
        # #####################################
        #
        # other options
        # eg.
        #   name = 'identity123'
        #   principal_id = principal.id
        #   secret = '123456'
        #   privilege_ids = [1,2]
        #   role_ids = [1]
        #
        #   identity = Identity.register(name, principal_id, secret, privilege_ids, role_ids)
        #
        #
        def register(name, principal_id, secret = nil, privileges = [], roles = [])
          payload = { name: name,
                      principal_id: principal_id,
                      privileges: privileges,
                      roles: roles }
          payload.merge(secret: secret) if !secret.nil? || secret != ''
          res = perform_post_request(IDENTITY_CREATE_URL, payload.to_json)
          raise_exception_identity(res) unless res.success?
          parsed = JSON.parse(res.body)['response']
          parsed.transform_keys!(&:to_sym)
          parsed[:secret] = secret if parsed[:secret].nil?
          new(parsed)
        end
      end
    end
  end
end
