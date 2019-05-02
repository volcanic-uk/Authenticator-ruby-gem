require 'volcanic/authenticator/v1/response_parser'

module Volcanic
  module Authenticator
    module V1
      # Helper for response handling
      module Response
        include ResponseParser
        # return for create identity
        def build_response(response, method)
          body = build_body response
          return body unless response.success?

          case method
          when 'identity'
            res_identity body
          when 'authority'
            res_authority body
          when 'group'
            res_group body
          when 'token'
            res_token body
          when 'key'
            res_key body
          when 'mtoken'
            res_token body
          else
            body
          end
        end
      end
    end
  end
end
