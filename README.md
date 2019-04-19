# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Installation

Add this line to your application's Gemfile:


```ruby
gem "volcanic-authenticator", git: "git@github.com:volcanic-uk/Authenticator-ruby-gem.git"
```

And then execute:

    $ bundle install

## Usage

```ruby
require 'volcanic/authenticator'

# Return Identity name and secret.
Volcanic::Authenticator.generate_identity(identity_name , group_ids) #eg. ('new_identity', [1,2])

# To issue a token. This will return a token
Volcanic::Authenticator.generate_token(identity_name, identity_secret) #eg. ('new_identity', 'qwertyuio1234567890')

# To validate token.
Volcanic::Authenticator.validate_token(token) 
 
# To blacklist/revoke token.
Volcanic::Authenticator.delete_token(token)
 
# To create Authority.
Volcanic::Authenticator.create_authority(authority_name, identity_id) #eg. ('new_authority', 1)
 
# To create Group.
Volcanic::Authenticator.create_group(group_name, identity_id, authority_ids) #eg. ('new_group', 1, [1,2])
```