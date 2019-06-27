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
