module Volcanic::Authenticator
  module V1
    # Helper for response handling
    module ErrorResponse
      def raise_exception_if_error(response, method = nil)
        raise ValidationError, parser(response.body, %w[reason message]) if response.code == 400
        raise AuthorizationError, parser(response.body, %w[error message]) if response.code == 401
        raise AppIdentityError if response.code == 403 && method == 'app_token'
        raise IdentityError, parser(response.body, %w[reason message]) if response.code == 403 && method == 'token'
        raise ConnectionError, 'end-point not found' if response.code == 404
      end

      def parser(json, keys)
        keys.reduce(JSON.parse(json)) { |found, item| found[item] }
      rescue TypeError
        raise ArgumentError, 'JSON key not found.'
      end
    end
  end
end
