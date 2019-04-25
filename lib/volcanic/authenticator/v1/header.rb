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
        'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTcwMjUwNTAsImlhdCI6MTU1NjE2MTA1MCwiaXNzIjoiVm9sY2FuaWMgYmV0dGVyIHBlb3BsZSB0ZWNobm9sb2d5IiwianRpIjoiZGRkNjU3NjAtNjcwNS0xMWU5LWIzNzctOTU1YWU2NmFlZDA0In0.AR8qU6OyEPSmPCbZRM2xlm2ml4DdnfCoKQYb-zA1bZNOsHULoqusW6GUexBZZucC5oCqSlRbVFk4nwFTGLkunMIvAId8mZ9EAlgSKbWv_daJdovYRdTv7cJUZhyNDZodk0lDNy9_urs3j3DG0im6m3ZDwQ2rQ195S9agtEhbVsok3BH9'
      end
    end
  end
end
