# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Error helper
    module Error
      # error handler for application token
      def raise_exception_app_token(res)
        code = res.code
        raise_exception_standard(res)
        raise ApplicationTokenError, parser(res.body, %w[message]) if code == 400
      end

      # error handler for permission
      def raise_exception_permission(res)
        code = res.code
        raise_exception_standard(res)
        raise PermissionError, parser(res.body, %w[message]) if code == 400
        raise PermissionError if code == 404
      end

      # error handler for service
      def raise_exception_service(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise ServiceError, parser(body, 'message') if code == 400
        raise ServiceError if code == 404
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
