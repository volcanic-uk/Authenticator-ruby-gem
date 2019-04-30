module Volcanic
  module Authenticator
    module V1
      # Helper for header creation
      module Header
        def bearer_header(token)
          { "Authorization": "Bearer #{token}",
            "Content-Type": 'application/json' }
        end

        # private

        # def auth_token(token)
        #   token || local_token
        # end
        #
        # def local_token
        #   token = Cache.new.mtoken
        #   return token unless token.nil?
        #
        #   perform_get_token
        # end
        #
        # def perform_get_token
        #   res = Connection.new.main_token
        #   JSON.parse(res)['token']
        # end
      end
    end
  end
end
