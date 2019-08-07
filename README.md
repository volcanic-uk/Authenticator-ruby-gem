# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Install
```ruby
gem 'volcanic-cache', git: 'git@github.com:volcanic-uk/ruby-cache.git'
gem 'volcanic-authenticator', git: 'git@github.com:volcanic-uk/Authenticator-ruby-gem.git'
```
[volcanic-cache](https://github.com/volcanic-uk/ruby-cache) is required to run this gem. 
    
## Configuration

Add the following to `config/application.rb`:
```ruby
# Authenticator server url
Volcanic::Authenticator.config.auth_url = 'https://auth.aws.local'

# Application name
Volcanic::Authenticator.config.app_name = 'app_name'

# Application secret
Volcanic::Authenticator.config.app_secret = 'app_secret' 
```

to configure expire time of token cache
```ruby
Volcanic::Authenticator.config.exp_token = 5 * 60 # default 5 minute
```

to configure expire time of application token cache
```ruby
Volcanic::Authenticator.config.exp_app_token = 5 * 60 # default 1 day
```

to configure expire time of public key cache
```ruby
Volcanic::Authenticator.config.exp_public_key = 5 * 60 # default 1 day
```

Note: all expire time are in seconds basis


## Usage

**Token**

attribute
`token_key`

create token 
```ruby
token = Volcanic::Authenticator::V1::Token.create(name, secret)
token.token_key # => 'eyJhbGciOiJFUzUxMiIsIn...'
```

validate token
```ruby
Volcanic::Authenticator::V1::Token.new(token_key).validate
# => true/false
```

validate token (remotely)
```ruby
Volcanic::Authenticator::V1::Token.new(token_key).remote_validate
# => true/false
```

fetch token claims
```ruby
token = Volcanic::Authenticator::V1::Token.new(token_key).fetch_claims
token.kid # => 'a5f53fa2...'
token.sub # => 'user://sandbox/-1/1/1/2'
token.iss # => 'volcanic_auth_service_ap2'
token.dataset_id # => -1
token.subject_id # => 1
token.principal_id # => 1
token.identity_id # => 2
```

revoke token (logout or blacklist token).
```ruby
Volcanic::Authenticator::V1::Token.new(token_key).revoke!
```

**Identity**

attributes `id`, `name`, `principal_id`, `secret`, `created_at`, `updated_at`

create identity
```ruby
name = 'any_name'
principal_id = 1 # need to create principal
identity = Volcanic::Authenticator::V1::Identity.create(name, principal_id)
identity.name # => 'any_name'
identity.secret # => random_password
```

create identity with custom secret
 ```ruby
 identity = Volcanic::Authenticator::V1::Identity.create(name, principal_id, secret: 'any_secret')
 identity.secret # => 'any_secret'
````

create identity with roles and privileges
 ```ruby
 roles = [1, 2] # ids of role
 privileges = [3, 4] # ids of privilege
 identity = Volcanic::Authenticator::V1::Identity.create(name, principal_id, privileges: privileges, roles: roles)
 ...
````

updating identity. (only applicable to `name` and `secret`)
```ruby
identity = Volcanic::Authenticator::V1::Identity.create(name, principal_id)
identity.name = 'new_name'
identity.secret = 'new_secret'
identity.save

# OR
 
Volcanic::Authenticator::V1::Identity.update(1, name: 'new_name', secret: 'new_secret')  
# 1 is the identity id
```

resetting identity secret
```ruby
Volcanic::Authenticator::V1::Identity.new(id: 1).reset_secret

# OR

Volcanic::Authenticator::V1::Identity.new(id: 1).reset_secret('custom_secret')
```

deleting identity
```ruby
Volcanic::Authenticator::V1::Identity.new(id: 1).delete
```

##Others
1. Service
2. Permission
3. Group
4. Privilege
5. Role
6. Principal


create
```ruby
# Service
name = 'any_name' 
service = Volcanic::Authenticator::V1::Service.create(name)
service.id # => 1
service.name # => 'any_name'
service.subject_id 
service.active? # => true/false
...

# Permission 
permission = Volcanic::Authenticator::V1::Permission.create(name, service.id, description)
permission.id
permission.name
permission.description
permission.subject_id
permission.service_id
permission.created_at
permission.updated_at
permission.active? # => true/false
...

# Group
permissions = [1, 2] # optional
group = Volcanic::Authenticator::V1::Group.create(name, description, permissions)
group.id
group.name
group.description
group.subject_id
group.created_at
group.updated_at
group.active? # => true/false
...

# Privilege
scope = 'vrn:sandbox:*:jobs/*' 
privilege = Volcanic::Authenticator::V1::Privilege.create(scope, permission.id, group.id) 
privilege.id
privilege.scope
privilege.permission_id
privilege.group_id
privilege.subject_id
privilege.created_at
privilege.updated_at
privilege.allow? # => true/false
privilege.allow! # to allow privilege
privilege.deny! # to deny privilege
...
# group id is optional

# Role
privileges = [1, 3] # optional
role = Volcanic::Authenticator::V1::Role.create(name, service.id, privileges)
role.id
role.name
role.service_id
role.subject_id
role.created_at
role.updated_at
...


# Principal
dataset_id = 1 
roles = [1, 2] # ids of roles. Optional
privileges = [1, 3] # ids of privilege. Optional
principal = Volcanic::Authenticator::V1::Principal.create(name, dataset_id, roles, privileges)
principal.id
principal.name
principal.dataset_id
principal.created_at
principal.updated_at
principal.active? # => true/false
```
find
```ruby
# example for service
service = Service.find(1) # find by id 
service.id
service.name
... 

# by page, page_size, query, sort, order, pagination

Service.find(page: 1, page_size: 2)
# => [ <Service:1>, <Service:2> ]
# page is the current page taken
# page_size is the size of the page 
# is deafault to page: 1, page_size: 10 
 
Service.find(query: 'vol') 
# => [ <Service:1 @name='volcanic'>, <Service:2 @name='volume'>, ... ]
# query is a character of field name. Typically it search for object that has name match with query.
# in case of Privilege, it search for the scope instead of name 

Service.find(sort: 'id', order: 'desc')  
# => [ <Service:1 @id = 10>, <Service:2 @id=9'>, ... ]    
# sort must be one of [id, name, created_at, updated_at]
# order must be one of [asc, desc]
        
Service.find(pagination: true)
# => { 
#       pagination: { page:1, pageSize:10, rowCount:10, pageCount: 1 }, 
#       data: [...] 
#    }   
# page is current page
# pageSize is the size of the data in a page
# rowCount is the total count of data
# pageCount is the total count of page.
# data is the array of Objects
# Note: by default pagination is set to false     
```

save
```ruby
# service
service.name 

# permission
permission.name
permission.description 

# group
group.name
group.description 

# privilege
privilege.scope 
privilege.permission_id 
privilege.group_id

# role
role.name 
role.service_id 
role.privileges 

# principal 
principal.name
principal.dataset_id 
```
delete

```ruby
# service
# permission
# group
# privilege
# role
# principal 
```
