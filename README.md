# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Installation

Add the following to your application's Gemfile:
```ruby
gem 'volcanic-cache', git: 'git@github.com:volcanic-uk/ruby-cache.git'

gem 'volcanic-authenticator', git: 'git@github.com:volcanic-uk/Authenticator-ruby-gem.git'
```

And run `bundle install`
    
## Setup

Add the following to `config/application.rb`:

required
```ruby
# Authenticator server url
Volcanic::Authenticator.config.auth_url = 'https://auth.aws.local'

# Application name
Volcanic::Authenticator.config.app_name = 'app_name'

# Application secret
Volcanic::Authenticator.config.app_secret = 'app_secret' 
```

optional
```ruby
# Cache expiration time for application token. Default 1 day
Volcanic::Authenticator.config.exp_app_token = 24 * 60 * 60 

# Cache expiration time for public key. Default 1 day
Volcanic::Authenticator.config.exp_public_key = 24 * 60 * 60  

# Cache expiration time for tokens. Default 5 minutes
Volcanic::Authenticator.config.exp_token = 5 * 60 

# Note: these expiration time are in seconds basis.
```

## Principal
**Create**

Create a new principal.

```ruby
principal = Volcanic::Authenticator::V1::Principal.create('principal-a', 1)
principal.id # => 1
principal.name # => 'principal-a'
principal.dataset_id # => 1
```

**Find by id**

Get a principal.
```ruby
# Principal.find_by_id(PRINCIPAL_ID)
principal =  Volcanic::Authenticator::V1::Principal.find_by_id(1)

principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<PRINCIPAL_ID>'
```

**Update**

Edit/Update a principal.
```ruby
principal = Volcanic::Authenticator::V1::Principal.find_by_id(1)
principal.name = 'new principal name'
principal.dataset_id = 2
principal.save
```

**Delete**

Delete a principal.
```ruby
principal = Volcanic::Authenticator::V1::Principal.find_by_id(1)
principal.delete

# OR
 
Volcanic::Authenticator::V1::Principal.new(id: 1).delete

```

## Identity
**Register**

Register a new identity.

```ruby
# params(identity_name, principal_id, identity_secret, privilege_ids, role_ids)
identity = Volcanic::Authenticator::V1::Identity.register('identity-a', 1, 'new_secret', [1,2], [2])
identity.id # => 1
identity.name # => 'principal-a'
identity.principal_id # => 1
identity.secret # => 'new_secret'
identity.token # => generate a token

# OR
 
# register without secret 
identity = Volcanic::Authenticator::V1::Identity.register('identity-a', 1)
identity.id # => 1
identity.name # => 'principal-a'
identity.principal_id # => 1
identity.secret # => generate a secret
identity.token # => generate a token

```

**Deactivate**
```ruby
identity = Volcanic::Authenticator::V1::Identity.register('identity-a', 1)
identity.deactivate

# OR
 
Volcanic::Authenticator::V1::Identity.new(id: 1).deactivate
```

## Token
**Create**
```ruby
# this will create a token object with token key
token = Volcanic::Authenticator::V1::Token.create('name', 'secret')
token.token_key # => generated token
```

**Validate**
```ruby
Volcanic::Authenticator::V1::Token.new(token_key).validate
# => true
```

**Validate by auth service**
```ruby
Volcanic::Authenticator::V1::Token.new(token_key).validate_by_service
# => true
```

**Fetch claims**
```ruby
token = Volcanic::Authenticator::V1::Token.new(token_key).decode_and_fetch_claims
token.kid # => key id claim
token.sub # => subject claim
token.iss # => issuer claim
token.dataset_id # => dataset id from subject
token.principal_id # => principal id from subject
token.identity_id # => identity id from subject
```

**Revoke token**
```ruby
Volcanic::Authenticator::V1::Token.new(token_key).revoke!
```