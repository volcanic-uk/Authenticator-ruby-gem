require "volcanic/authenticator/v1/cache"

module Volcanic
  module Authenticator
  module Response

    #return for create identity
    def return_identity(response)
      return response.body unless response.success?
      build_payload({
                        identity_name: parser(response.body)['identity']['name'],
                        identity_secret: parser(response.body)['identity']['secret'],
                        identity_id: parser(response.body)['identity']['id']
                    })
    end

    #return for create Authority
    def return_authority(response)
      return response.body unless response.success?
      build_payload({
                        authority_name: parser(response.body)['authority']['name'],
                        authority_id: parser(response.body)['authority']['id']
                    })
    end

    #return for create Group
    def return_group(response)
      return response.body unless response.success?
      build_payload({
                        group_name: parser(response.body)['group']['name'],
                        group_id: parser(response.body)['group']['id']
                    })
    end

    #return for issue token
    def return_token(response)
      return response.body unless response.success?
      token = parser(response.body)['token']
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

    def parser(json)
      JSON.parse(json)
    end

  end
  end
end