module Volcanic
  module Authenticator
  module Header

    def bearer_header(token)
      {
          "Authorization": "Bearer #{token}",
          "Content-Type": "application/json"
      }
    end
  end
  end
end
