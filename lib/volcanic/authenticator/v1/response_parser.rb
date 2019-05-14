module Volcanic
  module Authenticator
    module V1
      ##
      # Response parser helper
      module ResponseParser
        def res_identity(body)
          build_payload(identity_name: parser(body, %w[response name]),
                        identity_secret: parser(body, %w[response secret]),
                        identity_id: parser(body, %w[response id]))
        end

        def res_token(body)
          token = parser(body, %w[response token])
          id = parser(body, %w[response id])
          [build_payload(token: token,
                         id: id), token]
        end

        def res_authority(body)
          build_payload(authority_name: parser(body, %w[response name]),
                        authority_id: parser(body, %w[response id]))
        end

        def res_group(body)
          build_payload(group_name: parser(body, %w[response name]),
                        group_id: parser(body, %w[response id]))
        end

        def res_key(body)
          parser body, %w[response key]
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
end
