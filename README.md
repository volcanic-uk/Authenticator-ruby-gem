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
Volcanic::Authenticator.config.auth_url = 'http://volcanic-auth.com'

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
##
# .create(PRINCIPAL_NAME, DATASET_ID) 
principal = Volcanic::Authenticator::V1::Principal.create('principal-a', 1)

principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<GENERATED_ID>'
```

**Retrieve all**

get/show all principals
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

**Retrieve by id**

Get a principal.
```ruby
##
# .retrieve(PRINCIPAL_ID)
principal =  Volcanic::Authenticator::V1::Principal.retrieve(1) 

principal.name # => 'principal_name'
principal.dataset_id # => 1
principal.id # => '<GENERATED_ID>'
```

**Update**

Edit/update a principal.
```ruby
##
# must be in hash format
# available attributes :name, :dataset_id
attributes = { name: 'principal-b', dataset_id: 2 }
         
##
# .update(PRINCIPAL_ID, ATTRIBUTES) 
Volcanic::Authenticator::V1::Principal.update(1, attributes)
```

**Delete**

Delete a principal.
```ruby
##
# .delete(PRINCIPAL_ID)
Volcanic::Authenticator::V1::Principal.delete(1) # (principal_id)
```

## Identity

Create a new identity.
**Register**
```ruby
##
# .register(IDENTITY_NAME, IDENTITY_SECRET, PRINCIPAL_ID) 
identity = Volcanic::Authenticator::V1::Identity.register('identity-a', '123456', 1)

identity.name # => 'identity-a'
identity.secret # => nil (secret is hide for security reason)
identity.principal_id # => 1
identity.id # => '<GENERATED_ID>'
identity.token #=> '<TOKEN>' 


##
# .register(IDENTITY_NAME) 
identity = Volcanic::Authenticator::V1::Identity.register('identity-b')

identity.name # => 'identity-b'
identity.secret # => '<GENERATED_SECRET>'
identity.principal_id # => nil
identity.id # => '<GENERATED_ID>'
identity.token #=> '<TOKEN>'
 
```
   
**Login**

Generate a token (using the identity name and secret).
```ruby
##
# .login(IDENTITY_NAME, IDENTITY_SECRET)
Volcanic::Authenticator::V1::Identity.login('identity-a', '123456')

# => '<TOKEN>'
```

**Validation**

Validate a token (locally).
```ruby
##
# .validate(TOKEN)
Volcanic::Authenticator::V1::Identity.validate('<TOKEN>') 

# => true/false
 
# Note: this method validate token by using the Public Key
```

**Validation(remotely)**

Validate a token (remotely).
```ruby
##
# .remote_validate(TOKEN)
Volcanic::Authenticator::V1::Identity.remote_validate('<TOKEN>') 

# => true/false
 
# Note: this method validate token by the Authenticator service  
```
**Logout**

Blacklist a token. 
```ruby
##
# .logout(TOKEN)
Volcanic::Authenticator::V1::Identity.logout('<TOKEN>')
```  

**Deactivate**

Deactivate an identity. All token associate to the identity will be blacklisted.
```ruby
##
# .deactivate(IDENTITY_ID, TOKEN)
Volcanic::Authenticator::V1::Identity.deactivate('<IDENTITY_ID>','<TOKEN>') 

``` 

## Permission
**Create**

Create a new permission.
```ruby
##
# .create(PERMISSION_NAME, DESCRIPTION)
permission = Volcanic::Authenticator::V1::Permission.create('permission-a', 'descriptions...')

permission.name # => 'permission-a'
permission.id # => '<GENERATED_ID>'
permission.creator_id  # => 1
permission.description # => 'descriptions...'

# Note: creator_id is the identity_id. 
```

**Retrieve all**

Get/show all permissions.
```ruby
Volcanic::Authenticator::V1::Permission.retrieve
# #=> return an array object
# [
#    {
#      "id": 1,
#      "name": "permission-a",
#      "description": 'new permission descriptions',
#      "creator_id": 1,
#      "active": 1,
#      "created_at": "2019-06-11T09:42:23.000Z",
#      "updated_at": "2019-06-11T09:42:23.000Z"
#    },
#    {
#      "id": 2,
#      "name": "permission-b",
#      "description": null,
#      "creator_id": 2,
#      "active": 0,
#      "created_at": "2019-06-11T09:42:23.000Z",
#      "updated_at": "2019-06-11T09:42:23.000Z"
#    }
#  ]
```

**Retrieve by id**

Get a permission.
```ruby
##
# .retrieve(PERMISSION_ID) 
permission = Volcanic::Authenticator::V1::Permission.retrieve(1) 

permission.name # => 'permission-a'
permission.id # => '<GENERATED_ID>'
permission.creator_id  # => 1
permission.description # => ' descriptions...'
permission.active # => 1

# Note: active if is equal to 1. deactivate if equal to 0
```

**Update** 

Edit/Update permission.
```ruby
##
# must be in hash format
# available attributes :name, :description
attributes = { name: 'permission-b', description: 'new descriptions...' }

##
# .update(PERMISSION_ID, ATTRIBUTES)
Volcanic::Authenticator::V1::Permission.update(1, attributes)
```

Delete a permission.
**Delete**
```ruby
##
# .delete(PERMISSION_ID) 
Volcanic::Authenticator::V1::Permission.delete(1)
```

## Group
**Create**

Create a new group permissions.
```ruby
##
# .create(GROUP_NAME, DESCRIPTION, PERMISSION_IDS)
group = Volcanic::Authenticator::V1::Group.create('group-a', 'description...', [1])

group.name # => 'group-a'
group.id # => '<GENERATED_ID>'
group.creator_id  # => 1
group.description # => 'description...'

# Note: PERMISSION_IDS is in array format 
```

**Retrieve all**

Get/Show all group permissions.
```ruby
Volcanic::Authenticator::V1::Group.retrieve
# #=> return an array object
# [
#    {
#      "id": 1,
#      "name": "group-a",
#      "description": "description...",
#      "creator_id": 1,
#      "active": 1,
#      "created_at": "2019-06-11T09:42:23.000Z",
#      "updated_at": "2019-06-11T09:42:23.000Z"
#    },
#    {
#      "id": 2,
#      "name": "group-b",
#      "description": null,
#      "creator_id": 2,
#      "active": 0,
#      "created_at": "2019-06-11T09:42:23.000Z",
#      "updated_at": "2019-06-11T09:42:23.000Z"
#    }
#  ]
```

**Retrieve by id**

Get a group permission.
```ruby
##
# .retrieve(GROUP_ID)
group = Volcanic::Authenticator::V1::Group.retrieve(1)

group.name # => 'group-a'
group.id # => '<GENERATED_ID>'
group.creator_id  # => 1
group.description # => 'description...'
group.active # => 1
```

**Update**

Edit/Update group permission.
```ruby
##
# must be in hash format
# available attributes :name, :description
attributes = { name: 'group-b', description: 'new descriptions...' }

##
# .update(GROUP_ID, ATTRIBUTES) 
Volcanic::Authenticator::V1::Group.update(1, attributes)
```

**Delete**

Delete group permission.
```ruby
##
# .delete(GROUP_ID) 
Volcanic::Authenticator::V1::Group.delete(1)
```

## Token

This is an token helper method.
```ruby
##
# .new(token)
token = Volcanic::Authenticator::V1::Token.new('<TOKEN>')

# to decode and fetch all available claims
token.decode_with_claims! 

token.kid # key id 
token.sub # subject 
token.iss # issuer 
token.dataset_id # dataset id
token.principal_id # principal id
token.identity_id # identity id
```
