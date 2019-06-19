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
        raise ApplicationTokenError, parser(body, %w[reason message]) if  code == 400
      end

      # default error handler
      def raise_exception_standard(res)
        code = res.code
        body = res.body
        raise SignatureError, parser(body, %w[reason message]) if code == 400 && parser(body, %w[reason errorCode]) == 3002
        raise AuthorizationError, parser(body, %w[error message]) if [401, 403].include?(code)
      end

      def parser(json, keys)
        keys.reduce(JSON.parse(json)) { |found, item| found[item] }
      rescue TypeError
        raise ArgumentError, 'JSON key not found.'
      end
    end
  end
end
