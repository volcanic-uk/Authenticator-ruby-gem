module Volcanic
  module Authenticator
  module Header

    def bearer_header(token = nil)
      api_token = token || "eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ9.eyJleHAiOjE1NTY4NTQyOTUsImlhdCI6MTU1NTk5MDI5NSwiaXNzIjoiVm9sY2FuaWMgYmV0dGVyIHBlb3BsZSB0ZWNobm9sb2d5IiwianRpIjoiNGJlMjhjOTAtNjU3OC0xMWU5LTk3OTktYmYyMWMyYmM2MGE4In0.AKe-V5X9e5kKNAjyB_Dg-1mUFnePpjCLAnEUDbwwXVNDqDzE9rKOJHkZEEGV2lhgt4E4uiYcBPCwX7LGB1TnUrwRAZqMqo2m-EdEtRnSJiJPnG2k034cQe9vMvcVfNMzk7QtFybAdG3wX_GdoQQ7DJsp3d5jXUDBRn3B1Jno2eKyEUgJ"
      {
          "Authorization": "Bearer #{api_token}",
          "Content-Type": "application/json"
      }
    end
  end
  end
end
