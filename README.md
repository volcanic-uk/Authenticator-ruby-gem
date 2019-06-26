
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

**Get all**

get/show all Privileges
```ruby
Volcanic::Authenticator::V1::Privilege.all

#  => return an array of Privilege objects
```

**Find by id**

Get a Privilege.
```ruby
#
# Privilege.find_by_id(PRIVILEGE_ID)
privilege =  Volcanic::Authenticator::V1::Privilege.find_by_id(1)

privilege.name # => 'Privilege-a'
privilege.id # => 1
privilege.permission_id # => 2
privilege.group_id # => 10
privilege.allow # => true

```

**Update**

Edit/Update a Privilege.
```ruby
##
# must be in hash format
# attributes :scope, :permission_id, :group_id
attributes = { name: 'privilege-b', permission_id: 2, group_id: 10 }
         
##
# Privilege.update(PRIVILEGE_ID, ATTRIBUTES) 
Volcanic::Authenticator::V1::Privilege.update(1, attributes)
```

**Delete**

Delete a Privilege.
```ruby
##
# Privilege.delete(PRIVILEGE_ID)
Volcanic::Authenticator::V1::Privilege.delete(1) 
```
