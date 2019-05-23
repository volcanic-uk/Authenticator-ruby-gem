require_relative 'response_parser'

module Volcanic::Authenticator
  module V1
    # Helper for response handling
    module Response
      include ResponseParser
      # return for create identity
      def build_response(response, method)
        body = response.body
        raise_exception_if_error response, method

        case method
        when 'identity'
          res_identity body
        when 'authority'
          res_authority body
        when 'group'
          res_group body
        when 'token'
          res_token body
        when 'app_token'
          res_token body
        when 'pkey'
          res_key body
        else
          body
        end
      end

      def raise_exception_if_error(response, method = nil)
        raise ValidationError, parser(response.body, %w[reason message]) if response.code == 400
        raise AuthorizationError, parser(response.body, %w[error message]) if response.code == 401
        raise AppIdentityError if response.code == 403 && method == 'app_token'
        raise IdentityError, parser(response.body, %w[reason message]) if response.code == 403 && method == 'token'
        raise URLError, 'end-point not found' if response.code == 404
      end
    end
  end

end
