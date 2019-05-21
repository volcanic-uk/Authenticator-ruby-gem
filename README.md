# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Installation

Add this line to your application's Gemfile:


```ruby
gem 'volcanic-cache', git: 'git@github.com:volcanic-uk/ruby-cache.git'
gem 'volcanic-authenticator', git: 'git@github.com:volcanic-uk/Authenticator-ruby-gem.git'
```
`volcanic-cache` gem is required to run `volcanic-authenticator`. Both gems are required to be added at the `Gemfile`

And then execute:

    $ bundle install
    
## Setup

Add these configurations to `config/application.rb`:

This is the authenticator server url:
```ruby
Volcanic::Authenticator.config.auth_url = 'http://vauth.com' # this is required
```
This is the `app_token` configurations:
```ruby
# It is required to generate `app_token`. 
# This token is use as an authorization header when register identity. 
Volcanic::Authenticator.config.app_name = 'app_name'
Volcanic::Authenticator.config.app_secret = 'app_secret' 
```

This is the expiration cache time for `app_token`: 
```ruby
Volcanic::Authenticator.config.exp_app_token = 24 * 60 * 60 # Default to 1 day.
```

This is the expiration cache time for `public_key`: 
```ruby
# This key is use to validate (decode) token.
Volcanic::Authenticator.config.exp_public_key = 24 * 60 * 60  # Default to 1 day. 
```

This is the expiration cache time for token:
```ruby
Volcanic::Authenticator.config.exp_token = 5 * 60 # Default to 5 minutes
```
Note: all expiration time are seconds basis.

## Usage

Register
```ruby
# 1) Standard identity register
identity = Volcanic::Authenticator::V1::Identity.new('app_name')
identity.name # => 'app_name'
identity.secret # => 'app_secret'
identity.id # => '<GENERATED_ID>'
 
# 2) With secret and group ids
identity = Volcanic::Authenticator::V1::Identity.new('app_name', 'app_secret', [1,2])
identity.name # => 'app_name'
identity.secret # => 'app_secret'
identity.id # => '<GENERATED_ID>'
  
# 3) Also available as below
identity = Volcanic::Authenticator::V1::Identity.new
identity.register('app_name', 'app_secret', [3,4])
identity.name # => 'app_name'
identity.secret # => 'app_secret'
identity.id # => '<GENERATED_ID>'

# 4) or using instance 
Volcanic::Authenticator::V1::Identity.register('app_name', 'app_secret', [3,4])
Volcanic::Authenticator::V1::Identity.name # => 'app_name'
Volcanic::Authenticator::V1::Identity.secret # => 'app_secret'
Volcanic::Authenticator::V1::Identity.id # => '<GENERATED_ID>'  
```
    
   
Login
```ruby
identity.login('other_name', 'other_secret')
identity.name # => 'other_name'
identity.secret # => 'other_secret'
identity.id # => '<GENERATED_ID>' 
identity.token # => '<GENERATED_TOKEN>'
identity.source_id # => '<GENERATED_SOURCE_ID>'
 
## or
 
Volcanic::Authenticator::V1::Identity.login('other_name', 'other_secret')
Volcanic::Authenticator::V1::Identity.name # => 'other_name'
Volcanic::Authenticator::V1::Identity.secret # => 'other_secret'
Volcanic::Authenticator::V1::Identity.id # => '<GENERATED_ID>'
Volcanic::Authenticator::V1::Identity.token # => '<GENERATED_TOKEN>'
Volcanic::Authenticator::V1::Identity.source_id # => '<GENERATED_SOURCE_ID>'
```
Validation
```ruby
identity.validation('<TOKEN>')
# => true/false
 
## or
 
Volcanic::Authenticator::V1::Identity.validation('<TOKEN>')
# => true/false
 
# '<TOKEN>' is identity.token 
```
Logout 
```ruby
identity.logout('<TOKEN>')
 
## or
  
Volcanic::Authenticator::V1::Identity.logout('<TOKEN>')
```  
Deactivate. 
```ruby
identity.deactivate('<IDENTITY_ID>','<TOKEN>')
 
## or
  
Volcanic::Authenticator::V1::Identity.deactivate('<IDENTITY_ID>','<TOKEN>')
 
# '<IDENTITY_ID>' is identity.id 
# note: Running this will deactivate the identity and login with the same identity (name and secret) will return an error.
``` 
 
Example
```ruby
require 'volcanic/authenticator'

identity = Volcanic::Authenticator::V1::Identity.instance

# REGISTER
identity.register('<IDENTITY_NAME>','<IDENTITY_NAME>')
identity.name
# => '<IDENTITY_NAME>' 
identity.secret 
# => '<IDENTITY_NAME>'
identity.id 
# => 1

# LOGIN 
identity.login(identity.name, identity.secret)
identity.token
# => '<GENERATED_TOKEN>'
identity.source_id
# => '<GENERATED_SOURCE_ID>'
 
# VALIDATE
identity.validation(identity.token)
# => true
 
# LOGOUT
identity.logout(identity.token)
# identity.token => nil
# identity.source_id => nil

# DEACTIVATE
identity.deactivate(identity.id, identity.token)
# identity.name => nil
# identity.secret => nil
# identity.id => nil
 
 
```