module Volcanic
  module Authenticator
    module V1
      # Helper for header creation
      module Header
        def bearer_header(token)
          { "Authorization": "Bearer #{token}",
            "Content-Type": 'application/json' }
        end
      end
    end
  end
end
