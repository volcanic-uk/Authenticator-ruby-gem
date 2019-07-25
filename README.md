# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

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

````

## Principal
**Create**

Create a new principal.

```ruby
# Principal.create(principal_name, dataset_id, role_ids, privilege_ids)
principal = Volcanic::Authenticator::V1::Principal.create('principal-a', 1, [1, 2], [3, 4])
principal.id # => 1
principal.name # => 'principal_name'
principal.dataset_id # => 1
```

**Find**

Find principals. 

```ruby
# Default. This will return 10 principal on the first page
principals = Volcanic::Authenticator::V1::Principal.find
principals.size # => 10
principal = principals[0]
principal.id # => 1
principal.name # => 'principal a'
...

# Get on different page. The page size is default by 10
principals = Volcanic::Authenticator::V1::Principal.find(page: 2)
principals.size # => 10
principals[0].id # => 11
...

# Get on different page size.
principals = Volcanic::Authenticator::V1::Principal.find(page: 2, page_size: 5)
principals.size # => 5
principals[0].id # => 6

# Search by key name.
principals = Volcanic::Authenticator::V1::Principal.find(page: 2, page_size: 5, key_name: 'vol')
principals.size # => 5
principals[0].name # => 'volcanic-a'
principals[1].name # => 'principal-volcanic'
principals[2].name # => 'volvo'
```

**Find by id**

Get a principal.
```ruby
principal =  Volcanic::Authenticator::V1::Principal.find_by_id(1)
principal.id # => 1
principal.name # => 'principal_name'
principal.dataset_id # => 1
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
Volcanic::Authenticator::V1::Principal.new(id: 1).delete
```

## Identity

**Create**

Create new identity
```ruby
# required params is name and principal_id
identity = Volcanic::Authenticator::V1::Identity.create('identity-name', 1)
identity.id #=> 1
identity.principal_id #=> 2
identity.name # => 'identity-name'
identity.secret #=> 'cded0d177c84163f1...'

# with custom secret
identity = Volcanic::Authenticator::V1::Identity.create('identity-name', 1, secret: 'my-secret')
identity.secret # => 'my-secret'

# with privilege ids
identity = Volcanic::Authenticator::V1::Identity.create('identity-name', 1, privileges: [1, 2])

# with role ids
identity = Volcanic::Authenticator::V1::Identity.create('identity-name', 1, roles: [1, 2])

```

**Delete**

Delete an identity
```ruby
# using existing instance object
identity.delete

# OR
  
Volcanic::Authenticator::V1::Identity.new(id: 1).delete

```

**Token**
```ruby
identity = Volcanic::Authenticator::V1::Identity.create('identity-name', 1)
identity.token # => 'eyJhbGciOiJFUzUxMiIsInR5cDgwMWExIn0...'
```
Note: This is another way to generate a token. Always use `Token.new.gen_token_key(identity_name, identity_secret).token_key` to create a token.

## Token

**Generate Token key**

To generate a token key. `identity_name` and `identity_secret` is required for this method
```ruby
Token.create(name, secret)
# => "eyJhbGciOiJFUzUxMiIsInR5c..."
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
Token.new(token_key).remote_validate
# => true
```

**Fetch claims**

To fetch claims and others like `dataset_id`, `principal_id` and `identity_id` of the token
```ruby
token = Token.new(token_key).fetch_claims
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

## Permission
**Create**

Create a new Permission.

```ruby
#
# Permission.create(PERMISSION_NAME, DESCRIPTION, SERVICE_ID) 
permission = Volcanic::Authenticator::V1::Permission.create('Permission-a', 'new permission', 1)
permission.name # => 'Permission-a'
permission.id # => '1'
permission.description # => 1
permission.subject_id # => 3
permission.service_id # => 10
...
```
**Find**

Find permission. 
```ruby
# this is returning an Array of permission

# Default. This will return 10 permission on the first page
permissions = Volcanic::Authenticator::V1::Permission.find
permissions.size # => 10
permission = permissions[0]
permission.id # => 1
permission.name # => 'permission a'
...

# Get on different page. The page size is default by 10
permissions = Volcanic::Authenticator::V1::Permission.find(page: 2)
permissions.size # => 10
permissions[0].id # => 11
...

# Get on different page size.
permissions = Volcanic::Authenticator::V1::Permission.find(page: 2, page_size: 5)
permissions.size # => 5
permissions[0].id # => 6

# Search by key name.
permissions = Volcanic::Authenticator::V1::Permission.find(page: 2, page_size: 5, key_name: 'vol')
permissions.size # => 5
permissions[0].name # => 'volcanic-a'
permissions[1].name # => 'permission-volcanic'
permissions[2].name # => 'volvo'

```

**Find by id**

Find permission by id.
```ruby
permission = Volcanic::Authenticator::V1::Permission.find_by_id(1)
permission.id # => 1
permission.name # => 'permission-a'
permission.description # => 1
permission.subject_id # => 3
permission.service_id # => 10
permission.active? # => true
```

**Update**

Update a permission.
```ruby
permission = Volcanic::Authenticator::V1::Permission.find_by_id(1)
permission.name = 'update name'
permission.description = 'update description'
permission.save
```

**Delete**

Delete a permission.
```ruby
permission = Volcanic::Authenticator::V1::Permission.find_by_id(1)
permission.delete

# OR

Volcanic::Authenticator::V1::Permission.new(id: 1).delete
```

## Group Permission
**Create**

Create a new Group.

```ruby
group = Volcanic::Authenticator::V1::Group.create('group-a', 'description', [1, 2])
group.name # => 'group-a'
group.id # => '1'
group.description # => 'description'
```

**Find**

Find groups 
```ruby
# this is returning an Array of group

# Default. This will return 10 group on the first page
groups = Volcanic::Authenticator::V1::group.find
groups.size # => 10
group = groups[0]
group.id # => 1
group.name # => 'group a'
...

# Get for different page. The page size is default by 10
groups = Volcanic::Authenticator::V1::group.find(page: 2)
groups.size # => 10
groups[0].id # => 11
...

# Get for different page size.
groups = Volcanic::Authenticator::V1::group.find(page: 2, page_size: 5)
groups.size # => 5
groups[0].id # => 6

# Search by key name.
groups = Volcanic::Authenticator::V1::group.find(page: 2, page_size: 5, key_name: 'vol')
groups.size # => 5
groups[0].name # => 'volcanic-a'
groups[1].name # => 'group-volcanic'
groups[2].name # => 'volvo'
```
**Update**

Update a group.
```ruby 
group = Volcanic::Authenticator::V1::Group.find_by_id(1)
group.name = 'new group name'
group.description = 'new group description'
group.save
```

**Delete**

Delete a group.
```ruby
Volcanic::Authenticator::V1::Group.new(id: 1).delete

# OR
 
group = Volcanic::Authenticator::V1::Group.find_by_id(1)
group.delete
```

## Privilege
**Create**

Create a new Privilege.

```ruby
#
# Privilege.create(PRIVILEGE_NAME, PERMISSION_ID, GROUP_NAME) 
privilege = Volcanic::Authenticator::V1::Privilege.create('privilege-a', 2, 10)

privilege.scope # => 'Privilege-a'
privilege.id # => 1
privilege.permission_id # => 2
privilege.group_id # => 10
```

**Find**

Find privileges
```ruby
# Default. This will return 10 service on the first page
privileges = Volcanic::Authenticator::V1::Privilege.find
privileges.size # => 10
privilege = privileges[0]
privilege.id # => 1
privilege.name # => 'service a'
...

# Get on different page. The page size is default by 10
privileges = Volcanic::Authenticator::V1::Privilege.find(page: 2)
privileges.size # => 10
privileges[0].id # => 11
...

# Get on different page size.
privileges = Volcanic::Authenticator::V1::Privilege.find(page: 2, page_size: 5)
privileges.size # => 5
privileges[0].id # => 6

# Search by key name.
privileges = Volcanic::Authenticator::V1::Privilege.find(page: 2, page_size: 5, key_name: 'vol')
privileges.size # => 5
privileges[0].name # => 'volcanic-a'
privileges[1].name # => 'service-volcanic'
privileges[2].name # => 'volvo'
```

**Find by id**

Find privilege by id
```ruby
privilege =  Volcanic::Authenticator::V1::Privilege.find_by_id(1)
privilege.name # => 'Privilege-a'
privilege.id # => 1
privilege.permission_id # => 2
privilege.group_id # => 10
privilege.allow # => true
```

**Update**

Update a privilege.
```ruby
privilege = Volcanic::Authenticator::V1::Privilege.find_by_id(1)
privilege.name = 'new-service-name'
privilege.save

Volcanic::Authenticator::V1::Privilege.find_by_id(1).name # => 'new-service-name'
```
**Delete**

Delete a privilege.
```ruby

Volcanic::Authenticator::V1::Privilege.new(id: 1).delete

## OR
 
privilege = Volcanic::Authenticator::V1::Privilege.find_by_id(1)
privilege.delete 
```

## Role
**Create**

Create a new role.

```ruby
role = Volcanic::Authenticator::V1::Role.create('role-a')
role.id # => 1
role.name # => 'role-a'
...
```

**Find**

Find roles. This returns an array of roles
```ruby
# Default. This will return 10 role on the first page
roles = Volcanic::Authenticator::V1::Role.find
roles.size # => 10
role = roles[0]
role.id # => 1
role.name # => 'role a'
...

# Get on different page. The page size is default by 10
roles = Volcanic::Authenticator::V1::Role.find(page: 2)
roles.size # => 10
roles[0].id # => 11
...

# Get on different page size.
roles = Volcanic::Authenticator::V1::Role.find(page: 2, page_size: 5)
roles.size # => 5
roles[0].id # => 6

# Search by key name.
roles = Volcanic::Authenticator::V1::Role.find(page: 2, page_size: 5, key_name: 'vol')
roles.size # => 5
roles[0].name # => 'volcanic-a'
roles[1].name # => 'role-volcanic'
roles[2].name # => 'volvo'
```
**Find by id**

Find role by id.
```ruby
#
# Role.find_by_id(role_ID)
role = Volcanic::Authenticator::V1::Role.find_by_id(1)
role.id # => 1
role.name # => 'role_name'
...

```
**Update**

Update a role.
```ruby
         
role = Volcanic::Authenticator::V1::Role.find_by_id(1)
role.name = 'new-role-name'
role.save

updated_role = Volcanic::Authenticator::V1::Role.find_by_id(1)
updated_role.name # => 'new-role-name'
```

**Delete**

Delete a role.
```ruby

Volcanic::Authenticator::V1::Role.new(id: 1).delete

## OR
 
role = Volcanic::Authenticator::V1::Role.find_by_id(1)
role.delete 

```