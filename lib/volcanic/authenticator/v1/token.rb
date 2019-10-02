# frozen_string_literal: true

require 'jwt'
require 'logger'
require 'httparty'
require_relative 'helper/request'
require_relative 'helper/error'
require_relative 'helper/app_token'
require_relative 'base'

module Volcanic::Authenticator
  module V1
    # TODO: fix test file
    # Token class
    class Token < Base
      include Error
      include Request

      VALIDATE_TOKEN_URL = 'api/v1/token/validate'
      GEN_TOKEN_URL = 'api/v1/identity/login'
      GEN_TOKEN_NON_CREDENTIAL_URL = 'api/v1/identity/token/generate'
      REVOKE_TOKEN_URL = 'api/v1/identity/logout'
      PRIVILEGES_URL = 'api/v1/privileges'
      EXCEPTION = :raise_exception_token

      attr_accessor :token_key
      attr_reader :kid, :exp, :sub, :nbf, :audience, :iat, :iss, :jti
      attr_reader :dataset_id, :subject_id, :principal_id, :identity_id

      def initialize(token_key)
        @token_key = token_key
        fetch_claims
      end

      class << self
        include Error
        include Request
        # create a token (login identity)
        # +name+ is the identity name
        # +secret+ is the identity secret
        # +principal_id+ is the principal_id
        # +audience+ a string array of audience. who/what the token can access
        def create(name, secret, principal_id, *audience)
          aud = [service_name, audience].flatten.compact
          payload = { name: name,
                      secret: secret,
                      principal_id: principal_id,
                      audience: aud }.to_json
          parsed = perform_post_and_parse(EXCEPTION,
                                          GEN_TOKEN_URL,
                                          payload, nil)
          new(parsed['token']).cache!
        end

        # request token on behalf of the identity. No
        # credentials such +name+ or +secret+ is needed.
        # +id+ is the identity id
        # +opts+ a hash object of configuration options to generate the token
        # options:
        # +:audience+ an array of strings of who can use the token
        # +:exp+ a expiry date. eg 'mm-dd-yyyy' or 1567180514000 epoch time in millisecond
        # +:nbf+ a not before date. eg 'mm-dd-yyyy' or 1567180514000 epoch time in millisecond
        # +:single_use+ a boolean to set if the token is a single use token
        def request(id, **opts)
          payload = { identity: { id: id },
                      audience: [service_name, opts[:audience]].flatten.compact,
                      expiry_date: opts[:exp],
                      single_use: opts[:single_use] || false,
                      nbf: opts[:nbf] }
          payload.delete_if { |_, value| value.nil? }
          parsed = perform_post_and_parse(EXCEPTION,
                                          GEN_TOKEN_NON_CREDENTIAL_URL,
                                          payload.to_json)
          new(parsed['token']).cache!
        end
      end

      def create_app_token
        payload = { name: app_name,
                    secret: app_secret,
                    principal_id: app_principal_id,
                    audience: [service_name].compact }.to_json
        perform_post_and_parse(:raise_exception_app_token,
                               GEN_TOKEN_URL,
                               payload, nil)
      end

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
        clear! if expired?
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
        clear! if expired?
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
      def clear!(token = token_key)
        cache.evict!(token) unless token.nil?
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
      def cache!
        cache.fetch token_key, expire_in: exp_token, &method(:token_key) unless jti # cache if not a single use token
        self
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
      #  #if contains namespace such as 'api/v1/users'
      #  token.authorize?('api:v1:users', 'index')
      #
      # Note: resource_id with nil value will send as '*' (all)
      def authorize?(controller, action, id = '*')
        fetch_claims if sub.nil?
        id = id.nil? ? '*' : id.to_s
        cache.fetch "#{controller}:#{action}:#{sub}:#{id}", expire_in: exp_authorize_token do
          perform_authorize(controller, action, id)
        end
      end

      # run both authenticate and authorize
      def authenticate_and_authorize?(*opts)
        remote_validate && authorize?(*opts)
      end

      def expired?
        exp < Time.now.to_i
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
        url = "#{PRIVILEGES_URL}/#{end_point}?subject=#{sub}"
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
        @jti = body['jti']

        sub_uri = URI(@sub)
        subject = sub_uri.path.split('/').map do |v|
          ['', 'undefined', 'null'].include?(v) ? nil : v.to_i
        end
        _, @dataset_id, @principal_id, @identity_id, @subject_id = subject
      end
    end
  end
end
