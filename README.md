# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Installation

Add this line to your application's Gemfile:


```ruby
gem "volcanic-authenticator", git: "git@github.com:volcanic-uk/Authenticator-ruby-gem.git"
```

or `mini-cache` branch:

```ruby
gem "volcanic-authenticator", git: "git@github.com:volcanic-uk/Authenticator-ruby-gem.git" , branch: 'v1'
```

And then execute:

    $ bundle install
    
## Setup

Add these to `application.rb`

To setup authenticator url.
```ruby
 Volcanic::Authenticator.config.auth_url = 'http://0.0.0.0:3000'
```

To setup main identity variables. These configuration is use to create `main_token`, where this token is use to request `identity_register` for the first time.
```ruby
 Volcanic::Authenticator.config.identity_name = 'Volcanic'
 Volcanic::Authenticator.config.identity_secret = '3ddaac80b5830cef8d5ca39d958954b3f4afbba2'
```

To setup `main_token` expiration time.
```ruby
 Volcanic::Authenticator.config.exp_main_token = 24 * 60 * 60 # value is base in seconds
```

To setup `public_key` expiration time.
```ruby
 Volcanic::Authenticator.config.exp_public_key = 24 * 60 * 60
```

To setup token expiration time.
```ruby
 Volcanic::Authenticator.config.exp_token = 5 * 60
```

## Usage

```ruby
require 'volcanic/authenticator'

# To create new Identity. This will return name, secret and id of identity.
Volcanic::Authenticator::V1::Method.identity_register(identity_name , group_ids) #eg. ('new_identity', [1,2])

# To deactivate Identity. This will return boolean value
Volcanic::Authenticator::V1::Method.identity_deactivate(identity_id, token) #eg. (1, 'qwertyuio1234567890.Bioasdknji029837y4rb')

# To issue a token. This will return a token
Volcanic::Authenticator::V1::Method.identity_login(identity_name, identity_secret) #eg. ('new_identity', 'qwertyuio1234567890')

# To validate token. Return boolean value
Volcanic::Authenticator::V1::Method.identity_validate(token) 
 
# To blacklist/revoke token. Return boolean value
Volcanic::Authenticator::V1::Method.identity_logout(token)
 
# To create Authority.
Volcanic::Authenticator::V1::Method.authority_create(authority_name, identity_id) #eg. ('new_authority', 1)
 
# To create Group.
Volcanic::Authenticator::V1::Method.group_create(group_name, identity_id, authority_ids) #eg. ('new_group', 1, [1,2])
```