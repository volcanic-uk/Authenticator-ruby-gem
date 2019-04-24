module Volcanic
  module Authenticator
    # Helper for header creation
    module Header
      def bearer_header(token = nil)
        { "Authorization": "Bearer #{auth_token token}",
          "Content-Type": 'application/json' }
      end

      private

      def auth_token(token)
        token || local_token
      end

      def local_token
        'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTY5Mzg5MzEsImlhdCI6MTU1NjA3NDkzMSwiaXNzIjoiVm9sY2FuaWMgYmV0dGVyIHBlb3BsZSB0ZWNobm9sb2d5IiwianRpIjoiNWE5MTIyOTAtNjYzZC0xMWU5LThjMWYtZjczMzg2ODMwMjk0In0.AdrS6inPA3eK0KSdnp1trkCfP3AFG5xDzry7iP0Uqt7eyZ28scsXHHON0byfY_BKMmNcmaXbcjtib1GQf81fE1UpAGEwl1uatpVqMaGnKN51K_5EqxP_fQd7NuAjqx7ggqCuBPKYNAjd35C3Vu_ZQqnakNwknEoKugi7PHFsGWzr3BrG'
      end
    end
  end
end
