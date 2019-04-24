require 'volcanic/authenticator/v1/cache'

module Volcanic
  module Authenticator
    # Helper for response handling
    module Response
      # return for create identity
      def return_identity(response)
        body = build_body response
        return body unless response.success?

        build_payload(identity_name: parser(body, %w[identity name]),
                      identity_secret: parser(body, %w[identity secret]),
                      identity_id: parser(body, %w[identity id]))
      end

      # return for create Authority
      def return_authority(response)
        body = build_body response
        return body unless response.success?

        build_payload(authority_name: parser(body, %w[authority name]),
                      authority_id: parser(body, %w[authority id]))
      end

      # return for create Group
      def return_group(response)
        body = build_body response
        return body unless response.success?

        build_payload(group_name: parser(body, %w[group name]),
                      group_id: parser(body, %w[group id]))
      end

      # return for issue token
      def return_token(response)
        body = build_body response
        return body unless response.success?

        token = parser(body, %w[token])
        return nil if token.nil?

        caching token
        build_payload(token: token)
      end

      def caching(token)
        return if token.nil?

        Cache.new(token).save
      end

      private

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
