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