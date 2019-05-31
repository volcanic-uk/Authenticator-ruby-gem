module Volcanic::Authenticator
  module V1
    # Helper for response handling
    module ErrorResponse

      def raise_exception_identity(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise IdentityError, parser(body, %w[reason message]) if code == 400 || code == 403
      end

      def raise_exception_app(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise ApplicationError, parser(body, %w[reason message]) if code == 400 || code == 403
      end

      def raise_exception_principal(res)
        code = res.code
        body = res.body
        raise_exception_standard(res)
        raise PrincipalError, parser(body, %w[reason message]) if code == 400
      end

      def raise_exception_standard(res)
        code = res.code
        body = res.body
        if code == 400 && parser(body, %w[reason errorCode]) == 3002
          raise KeyError, parser(body, %w[reason message])
        end
        raise AuthorizationError, parser(body, %w[error message]) if code == 401
        raise ConnectionError, 'end-point not found' if code == 404
      end

      def parser(json, keys)
        keys.reduce(JSON.parse(json)) { |found, item| found[item] }
      rescue TypeError
        raise ArgumentError, 'JSON key not found.'
      end
    end
  end
end