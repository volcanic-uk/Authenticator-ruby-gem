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

## Service
**Create**

Create a new service.

```ruby
service = Volcanic::Authenticator::V1::Service.create('service-a')
service.name # => 'service-a'
service.id # => '1'
```

**Find**

Find services. This returns an array of services
```ruby
# Default. This will return 10 service on the first page
services = Volcanic::Authenticator::V1::Service.find
services.size # => 10
service = services[0]
service.id # => 1
service.name # => 'service a'
...

# Get on different page. The page size is default by 10
services = Volcanic::Authenticator::V1::Service.find(page: 2)
services.size # => 10
services[0].id # => 11
...

# Get on different page size.
services = Volcanic::Authenticator::V1::Service.find(page: 2, page_size: 5)
services.size # => 5
services[0].id # => 6

# Search by key name.
services = Volcanic::Authenticator::V1::Service.find(page: 2, page_size: 5, key_name: 'vol')
services.size # => 5
services[0].name # => 'volcanic-a'
services[1].name # => 'service-volcanic'
services[2].name # => 'volvo'
```

**Find by id**

Get a service.
```ruby
#
# Service.find_by_id(service_ID)
service = Volcanic::Authenticator::V1::Service.find_by_id(1)
service.name # => 'service_name'
service.id # => '<service_ID>'
service.active? # => true
```

**Update**

Edit/Update a service.
```ruby
         
service = Volcanic::Authenticator::V1::Service.find_by_id(1)
service.name = 'new-service-name'
service.save

updated_service = Volcanic::Authenticator::V1::Service.find_by_id(1)
updated_service.name # => 'new-service-name'
```

**Delete**

Delete a service.
```ruby

Volcanic::Authenticator::V1::Service.new(id: 1).delete

## OR
 
service = Volcanic::Authenticator::V1::Service.find_by_id(1)
service.delete 

```
## Token

**Generate Token key**

To generate a token key. `identity_name` and `identity_secret` is required for this method
```ruby
token = Token.new.gen_token_key(identity_name, identity_secret)
token.token_key # => "eyJhbGciOiJFUzUxMiIsInR5c..."
```

**Validate Token Key**

To validate token key using keystore. Validate of signature, expiry date, and content 
```ruby
Token.new(token_key).validate
# => true
```

**Validate Token Key by Auth Service**

To validate token key by using Auth Service. This method request an api validation of the token key to auth service.
```ruby
Token.new(token_key).validate_by_service
# => true
```

**Fetch claims**

To fetch claims and others like `dataset_id`, `principal_id` and `identity_id` of the token
```ruby
token = Token.new(token_key).decode_and_fetch_claims
token.kid # => key id claim
token.sub # => subject claim
token.iss # => issuer claim
token.dataset_id # => dataset id from sub
token.principal_id # => principal id from sub
token.identity_id # => identity id from su

```

**Revoke Token Key**

To revoke/blacklist token key from the auth service. This will also remove the token key at the gem's cache if it available.
```ruby
Token.new(token_key).revoke!
```