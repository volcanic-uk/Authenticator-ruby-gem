module Volcanic::Authenticator
  module Response

    #return for create identity
    def self.identity(response)
      return build_error response unless response.success?
      build_payload({
                        identity_name: JSON.parse(response.body)['identity']['name'],
                        identity_secret: JSON.parse(response.body)['identity']['secret']
                    })
    end

    #return for create Authority
    def self.authority(response)
      return build_error response unless response.success?
      build_payload({

                    })
    end

    #return for create Group
    def self.group(response)
      return build_error response unless response.success?
      build_payload({

                    })
    end

    #return for issue token
    def self.token(response)
      return build_error response unless response.success?
      build_payload({
                        token: JSON.parse(response.body)['token']
                    })
    end

    private

    def self.build_payload(body)
      {status: 'success'}.merge(body).to_json
    end

    def self.build_error(error)
      {
          status: 'error',
          error: {
              code: error.code,
              result: JSON.parse(error.body)['result'].nil? ? nil : JSON.parse(error.body)['result'],
              reason: JSON.parse(error.body)['reason'].nil? ? nil : JSON.parse(error.body)['reason']
          }
      }.to_json
    end

    def self.build_boolean_return(response)
      return true
    end

  end
end