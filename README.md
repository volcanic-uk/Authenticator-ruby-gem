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

Edit/Update a permission.
```ruby
permission = Volcanic::Authenticator::V1::Permission.find_by_id(1)
permission.name = 'update name'
permission.description = 'update description'
permission.save

# OR
 
Volcanic::Authenticator::V1::Permission.new(id: 1, name: 'update name', description: 'new description').save
# this will update field name and description of permission of id 1
```

**Delete**

Delete a permission.
```ruby
permission = Volcanic::Authenticator::V1::Permission.find_by_id(1)
permission.delete

# OR

Volcanic::Authenticator::V1::Permission.new(id: 1).delete
```

## Service
**Create**

Create a new service.

```ruby
#
# Service.create(SERVICE_NAME) 
service = Volcanic::Authenticator::V1::Service.create('service-a')

service.name # => 'service-a'
service.id # => '1'

```

**Get all**

get/show all services
```ruby
Volcanic::Authenticator::V1::Service.all

#  => return an array of service objects
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

Volcanic::Authenticator::V1::Service.new(1).delete

## OR
 
service = Volcanic::Authenticator::V1::Service.find_by_id(1)
service.delete 

```
