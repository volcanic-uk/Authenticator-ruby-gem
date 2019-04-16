module Volcanic::Authenticator
  module Header

    def bearer_header(token)
      {
          Authorization: "Bearer #{token}"
      }.to_json
    end
  end
end
