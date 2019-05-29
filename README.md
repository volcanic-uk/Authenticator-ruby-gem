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

required
```ruby
# Authenticator server url
Volcanic::Authenticator.config.auth_url = 'http://vauth.com'
# Application token configurations
Volcanic::Authenticator.config.app_name = 'app_name'
Volcanic::Authenticator.config.app_secret = 'app_secret' 
Volcanic::Authenticator.config.app_issuer = 'app_issuer' 
```

optional
```ruby
# Cache expiration time for application token. Default 1 day
Volcanic::Authenticator.config.exp_app_token = 24 * 60 * 60 
# Cache expiration time for public key. Default 1 day
Volcanic::Authenticator.config.exp_public_key = 24 * 60 * 60  
# Cache expiration time for tokens. Default 5 minutes
Volcanic::Authenticator.config.exp_token = 5 * 60 

# all must base in seconds
```

## Principal
Create
```ruby
principal = Volcanic::Authenticator::V1::Principal.create('principal_name', 1)
principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<GENERATED_ID>'
```

Retrieve/Get
```ruby
Volcanic::Authenticator::V1::Principal.retrieve
# => return and array of principals

principal =  Volcanic::Authenticator::V1::Principal.retrieve(1)
principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<GENERATED_ID>'
```

## Identity

Register
```ruby
# 1) Standard identity register
identity = Volcanic::Authenticator::V1::Identity.register('app_name', 'app_secret', 1)
identity.name # => 'app_name'
identity.secret # => 'app_secret'
identity.principal_id # => 1
identity.id # => '<GENERATED_ID>'
identity.token #=> '<GENERATED_TOKEN>' this is basically a login method

# note that secret is optional. Register identity without a secret will return a generated secret
```
   
Login
```ruby
Volcanic::Authenticator::V1::Identity.login('name', 'secret', 'issuer')
# => '<GENERATED_TOKEN>'
```
Validation
```ruby
Volcanic::Authenticator::V1::Identity.validate('<GENERATED_TOKEN>')
# => true/false
```
Logout 
```ruby
Volcanic::Authenticator::V1::Identity.logout('<GENERATED_TOKEN>')
# exception error raise if failed on server site
```  

Deactivate
```ruby
Volcanic::Authenticator::V1::Identity.deactivate('<GENERATED_ID>','<GENERATED_TOKEN>')
# exception error raise if failed on server site
``` 

## Token
```ruby
#initialise token 
token = Volcanic::Authenticator::V1::Token.new('<GENERATED_TOKEN>')

# decode a token
token.decode!
# will return an array value of payload and header token

# decode and fetch claims
token.decode_with_claims! 
token.kid # key id 
token.sub # subject 
token.iss # issuer 
token.dataset_id # dataset id
token.principal_id # principal id
token.identity_id # identity id
```