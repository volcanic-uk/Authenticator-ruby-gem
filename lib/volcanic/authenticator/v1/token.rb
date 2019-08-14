# frozen_string_literal: true

require 'jwt'
require 'logger'
require 'httparty'
require_relative 'helper/request'
require_relative 'helper/error'
require_relative 'helper/app_token'

module Volcanic::Authenticator
  module V1
    # Token class
    # method => :validate, :validate_by_service, :decode_and_fetch_claims, :cache! :revoke!
    # attr => :token, :kid, :sub, :iss, :dataset_id, :principal_id, :identity_id
    class Token
      extend Forwardable
      include Error
      include Request
      extend Error
      extend Request

      def_instance_delegator 'Volcanic::Cache::Cache'.to_sym, :instance, :cache
      def_instance_delegators 'Volcanic::Authenticator.config'.to_sym, :exp_token, :auth_url, :service_name, :exp_authorize_token

      VALIDATE_TOKEN_URL = 'api/v1/token/validate'
      GENERATE_TOKEN_URL = 'api/v1/identity/login'
      REVOKE_TOKEN_URL = 'api/v1/identity/logout'
      PRIVILEGES_URL = 'api/v1/privileges'
      EXCEPTION = :raise_exception_token

      attr_accessor :token_key
      attr_reader :kid, :exp, :sub, :nbf, :audience, :iat, :iss
      attr_reader :dataset_id, :subject_id, :principal_id, :identity_id

      def initialize(token_key = nil)
        @token_key = token_key
      end

      #
      # creating a token (login identity)
      #
      # eg.
      #   token = Token.create(name, secret)
      #   token.token_key # => 'eyJhbGciOiJFUzUxMiIsIn...'
      #   token.validate
      #   ...
      #
      def self.create(name, secret)
        payload = { name: name, secret: secret }.to_json
        parsed = perform_post_and_parse(EXCEPTION,
                                        GENERATE_TOKEN_URL,
                                        payload, nil)
        new(parsed['token']).cache! true
      end

      #
      # eg.
      #   token = Token.new.gen_token_key(name, secret)
      #   token.token_key # => 'eyJhbGciOiJFUzUxMiIsIn...'
      #   ....
      #
      # def gen_token_key(name, secret)
      #   payload = { name: name, secret: secret }.to_json
      #   parsed = perform_post_and_parse EXCEPTION, GENERATE_TOKEN_URL, payload, nil
      #   @token_key = parsed['token']
      #   cache!
      #   self
      # end

      #
      # to validate token exists at cache or has a valid signature.
      # eg.
      #   Token.new(token_key).validate
      #   # => true/false
      #
      def validate
        return true if cache.key?(token_key)

        verify_signature # verify token signature
        cache! # if success, token is cache again
        true
      rescue TokenError
        false
      end

      #
      # to validate token by authenticator service
      #
      # eg.
      #   Token.new(token_key).validate_by_service
      #   # => true/false
      #
      def remote_validate
        return true if cache.key?(token_key)

        res = HTTParty.post("#{auth_url}/#{VALIDATE_TOKEN_URL}",
                            headers: bearer_header(token_key))
        cache! if res.success?
        # Logger.new(STDOUT).error(JSON.parse(res.body)['message']) unless res.success?
        res.success?
      end

      #
      # fetching claims.
      #
      # eg.
      #  token = Token.new(token_key).fetch_claims
      #  token.kid # => key id
      #  token.sub # => subject
      #  token.iss # => issuer
      #  token.dataset_id # => dataset id
      #  token.principal_id # => principal id
      #  token.identity_id # => identity id
      #
      def fetch_claims
        claims_extractor
        self
      end

      #
      # to clear token from cache
      # eg.
      #   Token.new(token_key).clear!
      def clear!
        cache.evict!(token_key) unless token_key.nil?
      end

      #
      # to blacklist token (logout)
      # eg.
      #   Token.new(token_key).revoke!
      #
      def revoke!
        clear!
        perform_post_and_parse EXCEPTION, REVOKE_TOKEN_URL, nil, token_key
      end

      # caching token
      def cache!(return_self = false)
        cache.fetch token_key, expire_in: exp_token, &method(:token_key)
        self if return_self
      end

      # to check token authorization
      # eg.
      #   token.authorize(controller_name, action_name, resource_id)
      #   # => true/false
      #
      #   token.authorize('jobs', 'create', 1)
      #   # => true
      #
      #   token.authorize('users', 'delete')
      #   # = > false
      #
      # Note: resource_id with nil value will send as '*' (all)
      def authorize?(controller, action, id = '*')
        fetch_claims if sub.nil?
        id = id.nil? ? '*' : id.to_s
        cache.fetch "#{controller}:#{action}:#{sub}:#{id}", expire_in: exp_authorize_token do
          perform_authorize(controller, action, id)
        end
      end

      private

      def perform_authorize(controller, action, id)
        privileges = fetch_privileges(controller, action)
        return false if privileges.empty?

        return privileges[0]['allow'] if privileges.count == 1

        allow?(privileges, controller, id)
      end

      def fetch_privileges(permission, action)
        end_point = [service_name, "#{permission}:#{action}"].join('/')
        url = "#{PRIVILEGES_URL}/#{end_point}?fullyQualifiedSubject=#{sub}"
        exception = :raise_exception_token
        perform_get_and_parse(exception, url, AppToken.request_app_token)
      end

      def allow?(privileges, permission, id)
        priorities = []
        subject = sub.split('/')
        privileges.each do |p|
          scope = p['scope'].split(':')
          stack = scope[1]
          dataset_id = scope[2]
          resource = scope.last.split('/')
          point = 0
          # check for accurate stack
          next unless ['*', subject[2]].include?(stack)

          # check for accurate dataset_id
          next unless ['*', subject[3]].include?(dataset_id)

          # check for accurate permission/resource type
          next unless permission == resource.first

          # check for accurate resource id
          next unless ['*', id].include?(resource.last)

          point += 10 if stack == subject[2]
          point += 30 if dataset_id == subject[3]
          point += 50 if resource.last == id
          point += 1 unless p['allow']
          priorities.push(priority: point, allow: p['allow'])
        end

        return false if priorities.nil?

        priorities.max_by { |p| p[:priority] }[:allow]
      end

      def verify_signature
        claims_extractor # to fetch KID from token
        decode!(Key.fetch_and_request(kid), true) # decode token with verify true
      end

      def decode!(public_key = nil, verify = false)
        JWT.decode token_key, public_key, verify, algorithm: 'ES512'
      rescue JWT::DecodeError => e
        raise TokenError, e
      end

      def claims_extractor
        decoded_token = decode!
        header = decoded_token.last
        body = decoded_token.first
        @kid = header['kid']
        @exp = body['exp']
        @sub = body['sub']
        @nbf = body['nbf']
        @audience = body['audience']
        @iat = body['iat']
        @iss = body['iss']

        sub_uri = URI(@sub)
        subject = sub_uri.path.split('/').map do |v|
          ['', 'undefined', 'null'].include?(v) ? nil : v.to_i
        end
        _, @dataset_id, @subject_id, @principal_id, @identity_id = subject
      end
    end
  end
end
