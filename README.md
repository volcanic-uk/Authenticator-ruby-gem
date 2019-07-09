
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
## Group permission
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

**Find by id**

Find group by id.
```ruby
group =  Volcanic::Authenticator::V1::Group.find_by_id(1)
group.name # => 'Group-a'
group.id # => '1'
group.description # => 1
group.active? # => true
```

**Update**

Edit/Update a Group.
```ruby 
group = Volcanic::Authenticator::V1::Group.find_by_id(1)
group.name = 'new group name'
group.description = 'new group description'
group.save
```

**Delete**

Delete a Group.
```ruby
Volcanic::Authenticator::V1::Group.new(id: 1).delete

# OR
 
group = Volcanic::Authenticator::V1::Group.find_by_id(1)
group.delete
```
