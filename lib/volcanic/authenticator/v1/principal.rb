require 'httparty'
require_relative 'header'
require_relative 'token_key'

module Volcanic::Authenticator
  module V1
    ##
    # This is Principal Api class
    class Principal
      extend Volcanic::Authenticator::V1::Header

      # URLS
      PRINCIPAL = 'api/v1/principal'
      PRINCIPAL_DELETE = 'api/v1/principal/delete'
      PRINCIPAL_UPDATE = 'api/v1/principal/update'

      class << self
        def create(name, dataset_id)
          payload = { name: name,
                      dataset_id: dataset_id }.to_json
          perform_post_request PRINCIPAL, payload
        end
        def retrieve(id = 'all')
          perform_get_request "#{PRINCIPAL}/#{id}"
        end
        def delete(id)
          perform_post_request "#{PRINCIPAL_DELETE}/#{id}"
        end
        def update(id)
          perform_post_request "#{PRINCIPAL_UPDATE}/#{id}"
        end

        private

        def perform_post_request(end_point, body = nil)
          url = Volcanic::Authenticator.config.auth_url
          HTTParty.post "#{url}/#{end_point}", body: body, headers: bearer_header(TokenKey.fetch_and_request_app_token)
        end

        def perform_get_request(end_point)
          url = Volcanic::Authenticator.config.auth_url
          HTTParty.get "#{url}/#{end_point}", headers: header
        end
      end
    end
  end
end
