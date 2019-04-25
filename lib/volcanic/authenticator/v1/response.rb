require 'volcanic/authenticator/v1/cache'

module Volcanic
  module Authenticator
    # Helper for response handling
    module Response
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
        else
          body
        end
      end

      def caching(token)
        return if token.nil?

        Cache.new.save_token token
      end

      private

      def res_identity(body)
        build_payload(identity_name: parser(body, %w[identity name]),
                      identity_secret: parser(body, %w[identity secret]),
                      identity_id: parser(body, %w[identity id]))
      end

      def res_token(body)
        token = parser(body, %w[token])
        caching token
        build_payload(token: token)
      end

      def res_authority(body)
        build_payload(authority_name: parser(body, %w[authority name]),
                      authority_id: parser(body, %w[authority id]))
      end

      def res_group(body)
        build_payload(group_name: parser(body, %w[group name]),
                      group_id: parser(body, %w[group id]))
      end

      def res_key(body)
        public_key = parser(body, %w[key])
        Cache.new.save_pkey public_key
        build_payload('requestID': parser(body, %w[requestID]),
                      'key': public_key)
      end

      def build_body(response)
        response.body
      end

      def build_payload(body)
        { status: 'success' }.merge(body).to_json
      end

      def parser(json, object)
        value = JSON.parse(json)
        object.each do |o|
          value = value[o]
        end
        value
      end
    end
  end
end
