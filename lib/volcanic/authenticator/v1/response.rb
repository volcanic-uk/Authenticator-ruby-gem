require "volcanic/authenticator/v1/cache"

module Volcanic
  module Authenticator
  module Response

    #return for create identity
    def return_identity(response)
      return response.body unless response.success?
      build_payload({
                        identity_name: JSON.parse(response.body)['identity']['name'],
                        identity_secret: JSON.parse(response.body)['identity']['secret'],
                        identity_id: JSON.parse(response.body)['identity']['id']
                    })
    end

    #return for create Authority
    def return_authority(response)
      return response.body unless response.success?
      build_payload({
                        authority_name: JSON.parse(response.body)['authority']['name'],
                        authority_id: JSON.parse(response.body)['authority']['id']
                    })
    end

    #return for create Group
    def return_group(response)
      return response.body unless response.success?
      build_payload({
                        group_name: JSON.parse(response.body)['group']['name'],
                        group_id: JSON.parse(response.body)['group']['id']
                    })
    end

    #return for issue token
    def return_token(response)
      return response.body unless response.success?
      token = get_token response
      return nil if token.nil?
      caching token
      build_payload({
                        token: token
                    })
    end

    def caching(token)
      return if token.nil?
      Cache.new(token).save
    end

    private

    def build_payload(body)
      {status: 'success'}.merge(body).to_json
    end

    def get_token(jsonObject)
      JSON.parse(jsonObject.body)['token']
    end

  end
  end
end