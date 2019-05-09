# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Installation

Add this line to your application's Gemfile:


```ruby
gem 'volcanic-cache', git: 'git@github.com:volcanic-uk/ruby-cache.git'
gem 'volcanic-authenticator', git: 'git@github.com:volcanic-uk/Authenticator-ruby-gem.git'
```
`volcanic-cache` gem is required to run `volcanic-authenticator`, so both gems must be gem 'volcanic-cache', git: 'git@github.com:volcanic-uk/ruby-cache.git'
 to application gemfile. 

And then execute:

    $ bundle install
    
## Setup

Add these configuration to `application.rb`:

To configure the Authenticator server url.
```ruby
 Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3000' 
```
To generate `main_token`, below configurations are required. `main_token` is needed as the authorization header when requesting `auth.identity_register()`
```ruby
 Volcanic::Authenticator.config.identity_name = 'Volcanic'
 Volcanic::Authenticator.config.identity_secret = '3ddaac80b5830cef8d5ca39d958954b3f4afbba2' 
```

To configure `main_token` expiration time. Default 1 day
```ruby
 Volcanic::Authenticator.config.exp_main_token = 24 * 60 * 60 
```

To configure `public_key` expiration time. Default 1 day
```ruby
 Volcanic::Authenticator.config.exp_public_key = 24 * 60 * 60
```

To configure token expiration time. Default 5 minutes
```ruby
 Volcanic::Authenticator.config.exp_token = 5 * 60
```

Note: all expiration time are base in seconds

## Usage

```ruby
require 'volcanic/authenticator'

auth = Volcanic::Authenticator::V1::Method.new

# To create new Identity. This will return name, secret and id of identity.
auth.identity_register(identity_name , group_ids) #eg. ('new_identity', [1,2])

# To deactivate Identity. This will return boolean value
auth.identity_deactivate(identity_id, token) #eg. (1, 'qwertyuio1234567890.Bioasdknji029837y4rb')

# To issue a token. This will return a token
auth.identity_login(identity_name, identity_secret) #eg. ('new_identity', 'qwertyuio1234567890')

# To validate token. Return boolean value
auth.identity_validate(token) 
 
# To blacklist/revoke token. Return boolean value
auth.identity_logout(token)

```

1. Register/Create Identity
    ```ruby
    Volcanic::Authenticator::V1::Method.new.identity_register('new_identity', [1,2])
    # 'new_identity' => identity name
    # [1,2] => group ids 
 
    ```
    return a json object:
    ```json
    {
        "status": "success",
        "identity_name": "new_identity",
        "identity_secret": "e9b0...525c",
        "identity_id": 1117
    }
    ```
2. Login Identity
    ```ruby
    Volcanic::Authenticator::V1::Method.new.identity_login('new_identity', 'e9b0...525c')
    # 'new_identity' => identity name
    # 'e9b0...525c' => identity secret
    ```
    return a json object:
    ```json
    {
        "status": "success",
        "token": "eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ...PvFD3Cwb",
        "id": "99392900-7224-11e9-8abf-2d8af972204e"
    }
    ```
3. Logout Identity (return boolean)
    ```ruby
    Volcanic::Authenticator::V1::Method.new.identity_logout('eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ...PvFD3Cwb')
    # 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ...PvFD3Cwb' => token
    ```    
4. Deactivate Identity (return boolean)
   ```ruby
    Volcanic::Authenticator::V1::Method.new.identity_deactivate(1117,'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ...PvFD3Cwb')
    # 1117 => identity id
    # 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ...PvFD3Cwb' => token
 
    ```    
5. Validate Identity (return boolean)
    ```ruby
    Volcanic::Authenticator::V1::Method.new.identity_validate('eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ...PvFD3Cwb')
    # 'eyJhbGciOiJFUzUxMiIsInR5cCI6IkpXVCJ...PvFD3Cwb' => token
    ```

