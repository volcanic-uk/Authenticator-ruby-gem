module Volcanic::Authenticator
  module Response

    #return for create identity
    def return_identity(response)
      return build_error response unless response.success?
      build_payload({
                        identity_name: JSON.parse(response.body)['identity']['name'],
                        identity_secret: JSON.parse(response.body)['identity']['secret']
                    })
    end

    #return for create Authority
    def return_authority(response)
      return build_error response unless response.success?
      build_payload({
                        authority_name: JSON.parse(response.body)['authority']['name'],
                        authority_id: JSON.parse(response.body)['authority']['id']
                    })
    end

    #return for create Group
    def return_group(response)
      return build_error response unless response.success?
      build_payload({

                    })
    end

    #return for issue token
    def return_token(response)
      return build_error response unless response.success?
      caching get_token(response)
      build_payload({
                        token: get_token(response)
                    })
    end

    private

    def build_payload(body)
      {status: 'success'}.merge(body).to_json
    end

    def build_error(error)
      {
          status: 'error',
          error: {
              code: error.code,
              result: JSON.parse(error.body)['result'].nil? ? nil : JSON.parse(error.body)['result'],
              reason: JSON.parse(error.body)['reason'].nil? ? nil : JSON.parse(error.body)['reason']
          }
      }.to_json
    end

    def caching(token)
      return if token.nil?
      Cache.new(token).save
    end

    def get_token(jsonObject)
      JSON.parse(jsonObject.body)['token']
    end

  end
end