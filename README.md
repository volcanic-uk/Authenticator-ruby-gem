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

## Permission
**Create**

Create a new Permission.

```ruby
#
# Permission.create(PERMISSION_NAME, DESCRIPTION, SERVICE_ID) 
permission = Volcanic::Authenticator::V1::Permission.create('Permission-a', 'new permission', 1)

permission.name # => 'Permission-a'
permission.id # => '1'
permission.creator_id # => 1
permission.description # => 1

```

**Get all**

get/show all Permissions
```ruby
Volcanic::Authenticator::V1::Permission.all

#  => return an array of Permission objects
```

**Find by id**

Get a permission.
```ruby
#
# Permission.find_by_id(PERMISSION_ID)
permission =  Volcanic::Authenticator::V1::Permission.find_by_id(1)

permission.name # => 'Permission-a'
permission.id # => '1'
permission.creator_id # => 1
permission.description # => 1
permission.active # => true

```

**Update**

Edit/Update a permission.
```ruby
##
# must be in hash format
# attributes :name
attributes = { name: 'Permission-b', description: "new description" }
         
##
# Permission.update(PERMISSION_ID, ATTRIBUTES) 
Volcanic::Authenticator::V1::Permission.update(1, attributes)
```

**Delete**

Delete a permission.
```ruby
##
# Permission.delete(PERMISSION_ID)
Volcanic::Authenticator::V1::Permission.delete(1) 
```