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

This is the authenticator server url. It is required for the gem.
```ruby
Volcanic::Authenticator.config.auth_url = 'http://vauth.com' 
```
This is the `app_token` configurations. It is required to generate `app_token`. This token is use as an authorization header when register identity. 
```ruby
Volcanic::Authenticator.config.app_name = 'app_name'
Volcanic::Authenticator.config.app_secret = 'app_secret' 
```
note: if all the above configurations is not set, error will occur.

This is the expiration cache time for `app_token`. Default to 1 day.
```ruby
Volcanic::Authenticator.config.exp_app_token = 24 * 60 * 60 
```

This is the expiration cache time for `public_key`. Default to 1 day. This key is use to validate (decode) token. 
```ruby
Volcanic::Authenticator.config.exp_public_key = 24 * 60 * 60
```

This is the expiration cache time for token. Default to 5 minutes
```ruby
Volcanic::Authenticator.config.exp_token = 5 * 60
```
Note: all expiration time are seconds basis.

## Usage

Register
```ruby
# 1) Standard identity register
identity = Volcanic::Authenticator::V1::Identity.new('app_name')
# identity.name => 'app_name'
# identity.secret => '<GENERATED_SECRET>'
# identity.id => '<GENERATED_ID>' 
 
# 2) With secret and group ids
identity = Volcanic::Authenticator::V1::Identity.new('app_name', 'app_secret', [1,2])
# identity.secret => 'app_secret'
  
# 3) Also available as below
identity = Volcanic::Authenticator::V1::Identity.new.register('new_name', 'new_password', [3,4])
# identity.name => 'new_name'
# identity.secret => 'new_password'
# identity.id => '<GENERATED_ID>'
```
    
   
Login
```ruby
# 1) by using current identity name and secret
identity.login
# identity.name => 'app_name'
# identity.secret => 'app_secret'
# identity.token => '<GENERATED_TOKEN>'
# identity.source_id => '<GENERATED_SOURCE_ID>'
# note: source_id is the token id (jti) 
  
# 2) To login other identity
identity_other = Volcanic::Authenticator::V1::Identity.new.login('other_name', 'other_secret')
# identity_other.name => 'other_name'
# identity_other.secret => 'other_secret'
# identity_other.token => '<GENERATED_TOKEN>'
# identity_other.source_id => '<GENERATED_SOURCE_ID>'
```
Validation
```ruby
# 1) Validate current token
identity.validation 
# => true/false
 
# 2) Validate other token
Volcanic::Authenticator::V1::Identity.new.validation(token)
# => true/false
```
Logout 
```ruby
# 1) by using current token
identity.logout
# identity.name => 'app_name'
# identity.secret => 'app_secret'
# identity.id => 1
# identity.token => nil
# identity.source_id => nil
 
# 2) To logout other token
Volcanic::Authenticator::V1::Identity.new.logout(token)
# note: this will logout the token given.
```  
Deactivate. 
```ruby
# 1) by using current identity 
identity.deactivate
# identity.name => nil
# identity.secret => nil
# identity.id => nil
# identity.token => nil
# identity.source_id => nil

# 2) To deactivate other identity
Volcanic::Authenticator::V1::Identity.new.deactivate(id, token)
# id is the identity id 
 
# note: Running this will deactivate the identity and login with the same identity (name and secret) will return an error.
 
``` 
 
Example
```ruby
require 'volcanic/authenticator'

# REGISTER
identity = Volcanic::Authenticator::V1::Identity.new('<IDENTITY_NAME>','<IDENTITY_SECRET')

identity.name
# => '<IDENTITY_NAME>' 
identity.secret 
# => '<IDENTITY_SECRET>'
identity.id 
# => 1

# LOGIN 
identity.login
identity.token
# => '<GENERATED_TOKEN>'
identity.source_id
# => '<GENERATED_SOURCE_ID>'
 
# VALIDATE
identity.validation
# => true

# LOGOUT
identity.logout
# identity.token => nil
# identity.source_id => nil

# DEACTIVATE
identity.deactivate  
# identity.name => nil
# identity.secret => nil
# identity.id => nil
```