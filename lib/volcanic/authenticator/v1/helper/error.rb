# frozen_string_literal: true

module Volcanic::Authenticator
  module V1
    # Error helper
    module Error
      # error handler for application token
      def raise_exception_app_token(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise ApplicationTokenError, parser(body, %w[message]) if code == 400
      end

      # error handler for group
      def raise_exception_group(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise GroupError, parser(body, %w[message]) if code == 400
        raise GroupError if code == 404
      end

      # default error handler
      def raise_exception_standard(res)
        code = res.code
        body = res.body
        raise SignatureError, parser(body, %w[message]) if code == 400 && parser(body, %w[errorCode]) == 3002
        raise AuthorizationError, parser(body, %w[message]) if [401, 403].include?(code)
      end

      def parser(json, keys)
        keys.reduce(JSON.parse(json)) { |found, item| found[item] }
      rescue TypeError
        raise ArgumentError, 'JSON key not found.'
      end
    end
  end
end
