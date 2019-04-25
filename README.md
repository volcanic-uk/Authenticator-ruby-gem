# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Installation

Add this line to your application's Gemfile:


```ruby
gem "volcanic-authenticator", git: "git@github.com:volcanic-uk/Authenticator-ruby-gem.git"
```

or `dev` branch:

```ruby
gem "volcanic-authenticator", git: "git@github.com:volcanic-uk/Authenticator-ruby-gem.git" , branch: 'dev'
```

And then execute:

    $ bundle install
    
## Setup

add these to envonrment variable:

```.yaml
vol_auth_domain: http://0.0.0.0:3000
vol_auth_redis: redis://localhost:6379/1
vol_auth_redis_exp_token_time: 5 # in minutes
vol_auth_redis_exp_pkey_time: 1 # in days
```

## Usage

```ruby
require 'volcanic/authenticator'

# To create new Identity. This will return name, secret and id of identity.
Volcanic::Authenticator.generate_identity(identity_name , group_ids) #eg. ('new_identity', [1,2])

# To deactivate Identity. This will return boolean value
Volcanic::Authenticator.deactivate_identity(identity_id, token) #eg. (1, 'qwertyuio1234567890.Bioasdknji029837y4rb')

# To issue a token. This will return a token
Volcanic::Authenticator.generate_token(identity_name, identity_secret) #eg. ('new_identity', 'qwertyuio1234567890')

# To validate token. Return boolean value
Volcanic::Authenticator.validate_token(token) 
 
# To blacklist/revoke token. Return boolean value
Volcanic::Authenticator.delete_token(token)
 
# To create Authority.
Volcanic::Authenticator.create_authority(authority_name, identity_id) #eg. ('new_authority', 1)
 
# To create Group.
Volcanic::Authenticator.create_group(group_name, identity_id, authority_ids) #eg. ('new_group', 1, [1,2])
```