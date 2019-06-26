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

## 1. Principal
**Create**

Create a new principal.

```ruby
#
# Principal.create(PRINCIPAL_NAME, DATASET_ID) 
principal = Volcanic::Authenticator::V1::Principal.create('principal-a', 1)

principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<PRINCIPAL_ID>'
```

**Retrieve all**

get/show all principals
```ruby
Volcanic::Authenticator::V1::Principal.all

#  => return an array of principal objects
```

**Retrieve by id**

Get a principal.
```ruby
#
# Principal.find_by_id(PRINCIPAL_ID)
principal =  Volcanic::Authenticator::V1::Principal.find_by_id(1)

principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<PRINCIPAL_ID>'
```

**Update**

Edit/Update a principal.
```ruby
##
# must be in hash format
# attributes :name, :dataset_id
attributes = { name: 'principal-b', dataset_id: 2 }
         
##
# Principal.update(PRINCIPAL_ID, ATTRIBUTES) 
Volcanic::Authenticator::V1::Principal.update(1, attributes)
```

**Delete**

Delete a principal.
```ruby
##
# Principal.delete(PRINCIPAL_ID)
Volcanic::Authenticator::V1::Principal.delete(1) 
```
