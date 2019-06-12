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

# Application token configurations.
# This attributes use to run Login method and returning a token (Application token)
Volcanic::Authenticator.config.app_name = 'app_name'
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

# all must base in seconds
```

## Principal
Create
```ruby
principal = Volcanic::Authenticator::V1::Principal.create('principal_name', 1)
# params => (principal_name, dataset_id)

principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<GENERATED_ID>'
```

Retrieve all
```ruby
Volcanic::Authenticator::V1::Principal.retrieve
# # => return an array object
# [
#    {
#     "id": 1,
#      "name": "principal-A",
#      "dataset_id": null,
#      "last_active_date": null,
#      "active": 1,
#      "created_at": "2019-06-11T09:41:48.000Z",
#      "updated_at": "2019-06-11T09:41:48.000Z"
#    },
#    {
#      "id": 2,
#      "name": "principal-B",
#      "dataset_id": 1,
#      "last_active_date": null,
#      "active": 0,
#      "created_at": "2019-06-11T09:41:59.000Z",
#      "updated_at": "2019-06-11T09:41:59.000Z"
#    }
#  ]
```

Retrieve by id
```ruby
principal =  Volcanic::Authenticator::V1::Principal.retrieve(1) # (principal_id)
principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<GENERATED_ID>'
```

Update
```ruby
attr = { name: 'new-principal-name',
         dataset_id: 2 }
Volcanic::Authenticator::V1::Principal.update(1, attr) # (principal_id, attributes(in hash))
# return exception if failed
```

Delete
```ruby
Volcanic::Authenticator::V1::Principal.delete(1) # (principal_id)
# return exception if failed
```

## Identity

Register
```ruby
identity = Volcanic::Authenticator::V1::Identity.register('app_name', 'app_secret', 1)
# params => (identity_name, identity_secret(optional), principal_id(optional))
# Register identity without a secret will return a generated secret

identity.name # => 'app_name'
identity.secret # => 'app_secret'
identity.principal_id # => 1
identity.id # => '<GENERATED_ID>'
identity.token #=> '<GENERATED_TOKEN>' this is basically a login method

```
   
Login
```ruby
Volcanic::Authenticator::V1::Identity.login('name', 'secret') # (identity_name, identity_secret)
# => '<GENERATED_TOKEN>'
```
Validation
```ruby
Volcanic::Authenticator::V1::Identity.validate('<GENERATED_TOKEN>') # (token)
# => true/false
```
Logout 
```ruby
Volcanic::Authenticator::V1::Identity.logout('<GENERATED_TOKEN>') # (token)
# exception error raise if failed on server site
```  

Deactivate
```ruby
Volcanic::Authenticator::V1::Identity.deactivate('<GENERATED_ID>','<GENERATED_TOKEN>') 
#  params => (identity_id, token)
# exception error raise if failed on server site
``` 

## Token
```ruby
#initialise token 
token = Volcanic::Authenticator::V1::Token.new('<GENERATED_TOKEN>') # (token)

# to decode and fetch all available claims
token.decode_with_claims! 
token.kid # key id 
token.sub # subject 
token.iss # issuer 
token.dataset_id # dataset id
token.principal_id # principal id
token.identity_id # identity id
```

## Permission
Create
```ruby
permission = Volcanic::Authenticator::V1::Permission.create('perm_name', 1, 'permission descriptions ...')
# params => (name, creator_id (identity id), descriptions(optional))

permission.name # => 'perm_name'
permission.id # => '<GENERATED_ID>'
permission.creator_id  # => 1
permission.description # => 'permission descriptions ...'
```

Retrieve all
```ruby
Volcanic::Authenticator::V1::Permission.retrieve
# #=> return an array object
# [
#    {
#      "id": 1,
#      "name": "permissionA",
#      "description": 'new permission descriptions',
#      "creator_id": 1,
#      "active": 1,
#      "created_at": "2019-06-11T09:42:23.000Z",
#      "updated_at": "2019-06-11T09:42:23.000Z"
#    },
#    {
#      "id": 2,
#      "name": "permissionB",
#      "description": null,
#      "creator_id": 2,
#      "active": 0,
#      "created_at": "2019-06-11T09:42:23.000Z",
#      "updated_at": "2019-06-11T09:42:23.000Z"
#    }
#  ]
```

Retrieve by id
```ruby
permission = Volcanic::Authenticator::V1::Permission.retrieve(1) # (permission_id)

permission.name # => 'perm_name'
permission.id # => '<GENERATED_ID>'
permission.creator_id  # => 1
permission.description # => 'permission descriptions ...'
permission.active # => 1
```

Update 
```ruby
attributes = { name: 'new_permission_name', 
               description: 'new descriptions ...' }
Volcanic::Authenticator::V1::Permission.update(1, attributes) # (permission_id, attr(in hash))
# return exception if failed  
```

Delete
```ruby
Volcanic::Authenticator::V1::Permission.delete(1) # (permission_id)
# return exception if failed   
```