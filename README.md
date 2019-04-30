# Volcanic::Authenticator::Method

A ruby for gem for Volcanic Authenticator

## Installation

Add this line to your application's Gemfile:


```ruby
gem "volcanic-authenticator", git: "git@github.com:volcanic-uk/Authenticator-ruby-gem.git"
```

or `mini-cache` branch:

```ruby
gem "volcanic-authenticator", git: "git@github.com:volcanic-uk/Authenticator-ruby-gem.git" , branch: 'mini-cache'
```

And then execute:

    $ bundle install
    
## Setup

add these to environment variable:

```.yaml
vol_auth_domain: http://0.0.0.0:3000 # Authenticator url
vol_auth_identity_name: identity_name # eg volcanic
vol_auth_identity_secret: identity_secret
vol_auth_cache_exp_external_token_time: 5 # in minutes. default 5 minutes
vol_auth_cache_exp_internal_token_time: 1 # in days. default 1 days
vol_auth_cache_exp_pkey_time: 1 # in days. default 1 days
```

## Usage

```ruby
require 'volcanic/authenticator'

# To create new Identity. This will return name, secret and id of identity.
Volcanic::Authenticator::Method.identity_register(identity_name , group_ids) #eg. ('new_identity', [1,2])

# To deactivate Identity. This will return boolean value
Volcanic::Authenticator::Method.identity_deactivate(identity_id, token) #eg. (1, 'qwertyuio1234567890.Bioasdknji029837y4rb')

# To issue a token. This will return a token
Volcanic::Authenticator::Method.identity_login(identity_name, identity_secret) #eg. ('new_identity', 'qwertyuio1234567890')

# To validate token. Return boolean value
Volcanic::Authenticator::Method.identity_validate(token) 
 
# To blacklist/revoke token. Return boolean value
Volcanic::Authenticator::Method.identity_logout(token)
 
# To create Authority.
Volcanic::Authenticator::Method.authority_create(authority_name, identity_id) #eg. ('new_authority', 1)
 
# To create Group.
Volcanic::Authenticator::Method.group_create(group_name, identity_id, authority_ids) #eg. ('new_group', 1, [1,2])
```