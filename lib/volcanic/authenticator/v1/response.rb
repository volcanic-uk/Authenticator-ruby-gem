require 'volcanic/authenticator/v1/response_parser'

module Volcanic
  module Authenticator
    module V1
      # Helper for response handling
      module Response
        include ResponseParser
        # return for create identity
        def build_response(response, method)
          body = response.body
          raise_error response, method, body

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

        def raise_error(response, method, body)
          raise InvalidAppToken if response.code == 400 && method == 'app_token'
          raise ValidationError, parser(body, %w[reason message]) if response.code == 400
          raise AuthorizationError, parser(body, %w[error message]) if response.code == 401
        end
      end
    end
  end
end
