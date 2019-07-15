# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Error helper
    module Error
      # error handler for application token
      def raise_exception_app_token(res)
        code = res.code
        raise_exception_standard(res)
        raise ApplicationTokenError, parser(res.body, 'message') if code == 400
      end

      # error handler for permission
      def raise_exception_permission(res)
        code = res.code
        raise_exception_standard(res)
        raise PermissionError, parser(res.body, 'message') if code == 400
        raise PermissionError if code == 404
      end

      # error handler for service
      def raise_exception_service(res)
        code = res.code
        raise_exception_standard(res)
        raise ServiceError, parser(res.body, 'message') if code == 400
        raise ServiceError if code == 404
      end

      # error handler for group
      def raise_exception_group(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise GroupError, parser(body, %w[message]) if code == 400
        raise GroupError if code == 404
      end

      # error handler for Privilege
      def raise_exception_privilege(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise PrivilegeError, parser(body, %w[message]) if code == 400
        raise PrivilegeError, 'not found' if code == 404
      end

      # error handler for role
      def raise_exception_role(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise RoleError, parser(body, 'message') if code == 400

        error_message = parser(body, 'errorCode' == 9001) ? parser(body, 'message') : 'url not found'
        raise(RoleError, error_message) if code == 404
      end

      # error handler for principal
      def raise_exception_principal(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise PrincipalError, parser(body, 'message') if code == 400
        raise PrincipalError if code == 404
      end

      # error handler for identity
      def raise_exception_identity(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise IdentityError, parser(body, 'message') if code == 400
      end

      # error handler for identity
      def raise_exception_token(res)
        code = res.code
        raise_exception_standard(res)
        raise TokenError, parser(res.body, 'message') if code == 400
        raise TokenError if code == 404
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
