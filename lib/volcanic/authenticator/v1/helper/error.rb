# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Error helper
    module Error
      # raise exception
      class RaiseException
        attr_reader :res, :status, :body, :exception

        def initialize(res, exception)
          @res = res
          @status = res.code
          @body = JSON.parse(res.body)
          @exception = exception
          raise_exception
        end

        private

        def raise_exception
          #
          standard_error
          #
          raise exception, message if [400, 404, 422].include?(status)
        end

        def standard_error
          raise SignatureError, message if status == 400 && error_code == 3002
          raise AuthorizationError, message if [401, 403].include?(status)
        end

        def message
          return "HTTP error #{status}" unless body.key?('message')

          body['message']
        end

        def error_code
          return '' unless body.key?('errorCode')

          body['errorCode']
        end
      end

      # error handler for application token
      def raise_exception_app_token(res)
        RaiseException.new(res, ApplicationTokenError)
      end

      # error handler for service
      def raise_exception_service(res)
        RaiseException.new(res, ServiceError)
      end

      def raise_exception_permission(res)
        RaiseException.new(res, PermissionError)
      end

      # error handler for group
      def raise_exception_group(res)
        RaiseException.new(res, GroupError)

        # code = res.code
        # body = res.body
        # raise_exception_standard(res)
        # raise GroupError, parser(body, %w[message]) if code == 400
        # raise GroupError if code == 404
      end

      # error handler for Privilege
      def raise_exception_privilege(res)
        RaiseException.new(res, PrivilegeError)

        # code = res.code
        # body = res.body
        # raise_exception_standard(res)
        # raise PrivilegeError, parser(body, %w[message]) if code == 400
        # raise PrivilegeError, 'not found' if code == 404
      end

      # error handler for role
      def raise_exception_role(res)
        RaiseException.new(res, RoleError)

        # code = res.code
        # body = res.body
        # raise_exception_standard(res)
        # raise RoleError, parser(body, 'message') if code == 400
        #
        # error_message = parser(body, 'errorCode' == 9001) ? parser(body, 'message') : 'url not found'
        # raise(RoleError, error_message) if code == 404
      end

      # error handler for principal
      def raise_exception_principal(res)
        RaiseException.new(res, PrincipalError)

        # code = res.code
        # body = res.body
        # raise_exception_standard(res)
        # raise PrincipalError, parser(body, 'message') if code == 400
        # raise PrincipalError if code == 404
      end

      # error handler for identity
      def raise_exception_identity(res)
        RaiseException.new(res, IdentityError)

        # code = res.code
        # body = res.body
        # raise_exception_standard(res)
        # raise IdentityError, parser(body, 'message') if [400, 404, 422].include? code
      end

      # error handler for identity
      def raise_exception_token(res)
        RaiseException.new(res, TokenError)

        # code = res.code
        # raise_exception_standard(res)
        # raise TokenError, parser(res.body, 'message') if code == 400
        # raise TokenError if code == 404
      end

      # default error handler
      def raise_exception_standard(res)
        code = res.code
        body = res.body
        raise SignatureError, parser(body, 'message') if code == 400 && parser(body, 'errorCode' == 3002)
        raise AuthorizationError, parser(body, 'message') if [401, 403].include?(code)
      end

      def parser(json, *key)
        keys = key.flatten.compact
        keys.reduce(JSON.parse(json)) { |found, item| found[item] }
      rescue TypeError
        raise ArgumentError, 'JSON key not found.'
      end
    end
  end
end
