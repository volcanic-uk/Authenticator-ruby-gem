module Volcanic::Authenticator
  module V1
    ##
    # Response parser helper
    module ResponseParser
      def res_identity(body)
        name = parser(body, %w[response name])
        secret = parser(body, %w[response secret])
        id = parser(body, %w[response id])
        [name, secret, id]
      end

      def res_token(body)
        token = parser(body, %w[response token])
        id = parser(body, %w[response id])
        [token, id]
      end

      def res_key(body)
        parser body, %w[response key]
      end

      # def res_authority(body)
      #   build_payload(authority_name: parser(body, %w[response name]),
      #                 authority_id: parser(body, %w[response id]))
      # end

      # def res_group(body)
      #   build_payload(group_name: parser(body, %w[response name]),
      #                 group_id: parser(body, %w[response id]))
      # end

      # def build_payload(body)
      #   { status: 'success' }.merge(body).to_json
      # end

      ##
      # as JSON parser to retrieve the desire value.
      def parser(json, keys)
        keys.reduce(JSON.parse(json)) { |found, item| found[item] }
      rescue TypeError
        raise ArgumentError, 'JSON key not found.'
      end
    end
  end
end
