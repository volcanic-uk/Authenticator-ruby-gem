# Volcanic::Authenticator

A ruby for gem for Volcanic Authenticator

## Getting Started

Install with:
```ruby
gem 'volcanic-cache', git: 'git@github.com:volcanic-uk/ruby-cache.git'

gem 'volcanic-authenticator', git: 'git@github.com:volcanic-uk/Authenticator-ruby-gem.git'
```

Configure these to `config/application.rb`:
```ruby
# +auth_url+: the domain for authenticator service
Volcanic::Authenticator.config.auth_url = 'https://auth.aws.local' 

# +app_name+: the application identity name 
# +app_secret+: the application identity secret
# +app_dataset_id+: the application dataset id
# please request these credentials from the authenticator admin.
Volcanic::Authenticator.config.app_name = 'app_name'
Volcanic::Authenticator.config.app_secret = 'app_secret' 
Volcanic::Authenticator.config.app_dataset_id = 'dataset_id' 

# If you are using auth in local development:
Volcanic::Authenticator.config.app_name = 'volcanic'
Volcanic::Authenticator.config.app_secret = 'volcanic!123' 
Volcanic::Authenticator.config.app_dataset_id = '-1'

### Optional ### 
# +exp_token+: the expiry time for token.
# +exp_app_token+: the expiry time for application token 
# +exp_public_key+: the expiry time for signature public key 
# below configurations are in seconds basis
Volcanic::Authenticator.config.exp_token = 300 # 5 minutes
Volcanic::Authenticator.config.exp_app_token = 24 * 60 * 60  # 1 day
Volcanic::Authenticator.config.exp_public_key = 24  # 24 seconds
```

## Features
**Identity**

To create a new identity (with random secret). This is the minimum requirement for creating an identity:
```ruby
identity = Volcanic::Authenticator::V1::Identity.create('name', 'principal_id')
identity.secret = '12ab...'
```
`principal_id ` can be retrieve when calling `principal.id`. See at Principal.

To create a new identity with secret
```ruby
identity = Volcanic::Authenticator::V1::Identity.create('name', 'principal_id', secret: '1234abcd')
identity.secret = '1234abcd'
```

To create a new identity with privilege ids or role ids
```ruby
identity = Volcanic::Authenticator::V1::Identity.create('name', 'principal_id', privilege_ids: [1, 2], role_ids: [3, 4])
identity.privilege_ids = [1, 2]
identity.role_ids = [3, 4]
```
see at Privilege or Roles features on retrieving the id.

Method/Attr available for `Identity` are:
```ruby
identity.id
identity.name
identity.secret
identity.privilege_ids
identity.role_ids
identity.principal_id
identity.dataset_id
identity.source
identity.created_at
identity.updated_at
```

To update name
```ruby
identity.name = 'new_name'
identity.save
```

To update privilege_ids 
```ruby
identity.update_privilege_ids([4, 5])
```

To update role_ids
```ruby
identity.update_role_ids([4, 5])
```

To reset secret
```ruby
identity.reset_secret('my_new_secret')
```

To reset secret with random value
```ruby
identity.reset_secret
identity.secret # => 'e7fb7...'
```

To login
```ruby
# login after successful create new identity
identity = Volcanic::Authenticator::V1::Identity.create('name', 'principal_id', secret: '1234abcd')
identity.login # => return a Token Object.

# login with new instance
Volcanic::Authenticator::V1::Identity.new(name: 'name', principal: 'principal_id', secret: '1234abcd').login # => return a Token Object.

# login with audience details
identity.login(['abc@123.com', '*']) 
```

To generate a token (login without credential)
```ruby
# minimum requirements
Volcanic::Authenticator::V1::Identity.new(id: 'identity_id').token # => return a token Object

# with options
#   +audience+: A set of information to tell who/what the token use for. It is a set strings array
#   +exp+: A token expiry time. only accept unix timestamp in milliseconds format.
#   +nbf+: A token not before time. token will be invalid until it reach nbf time. only accept unix timestamp in milliseconds format.
#   +single_use+: If set to true, token can only be use once. 
Volcanic::Authenticator::V1::Identity.new(id: 'identity_id').token(audience: ['abc@123.com'], exp: 1571296171000, nbf: 1571296171000, single_use: false)
# => return a token object
```

**Token**

When initializing a token
```ruby
token = Token.new(jwt_token)
token.token_base64
# below are all the claims and information that been extract
token.kid 
token.sub
token.exp
token.nbf
token.audience
token.iat
token.iss
token.jti
token.stack_id
token.dataset_id
token.principal_id
token.identity_id
```

To validate token. This method validate token locally by checking its signature key.
WARNING: this method may not be accurate due to it cannot know whether the token already been revoke or not.
```ruby
token.validate #=> true/false
```

To validate token by authenticator service. (more accurate!)
```ruby
token.remote_validate #=> true/false
```

To revoke token. This is a one way method. Token will be revoke forever and cannot be use anymore.
```ruby
token.revoke!
```

**Principal**

To create a new principal.
```ruby
Volcanic::Authenticator::V1::Principal.create('name', 'dataset_id')
```

To create a new principal with privilege and role ids
```ruby
privilege_ids = [1, 2]
role_ids = [3, 4]
Volcanic::Authenticator::V1::Principal.create('name', 'dataset_id', privilege_ids, role_ids)
```

attributes in principal:
```ruby
principal.id
principal.name
principal.dataset_id
principal.privilege_ids
principal.role_ids
principal.active?
principal.created_at
principal.updated_at
```

To update principal name
```ruby
principal.name = 'new_principal_name'
principal.save
```

To update principal privilege_ids 
```ruby
principal.update_privilege_ids([4, 5])
```

To update principal role_ids
```ruby
principal.update_role_ids([4, 5])
```

To delete a principal
```ruby
principal.delete
```

To find principal by id
```ruby
Volcanic::Authenticator::V1::Principal.find_by_id('principal_id')
```

To find principal in collections
```ruby
# search for name
principals = Volcanic::Authenticator::V1::Principal.find(query: 'principal')
principals[0].name # => 'principal-A'
principals[1].name # => 'principal-B'

# search for dataset_id
Volcanic::Authenticator::V1::Principal.find(dataset_id: '1')

# search by page. by default it returns the first page that has 15 collections
Volcanic::Authenticator::V1::Principal.find(page: 1)

# search by page size.
Volcanic::Authenticator::V1::Principal.find(page: 2, page_size: 2) # this return the 2nd page with 2 collections

# sorting the collections by field
Volcanic::Authenticator::V1::Principal.find(sort: 'id') # sort by id
Volcanic::Authenticator::V1::Principal.find(sort: 'name') # sort by name
...

# sort in order
Volcanic::Authenticator::V1::Principal.find(sort: 'id', order: 'asc')  # in ascending order
Volcanic::Authenticator::V1::Principal.find(sort: 'id', order: 'desc') # in descending order
#
```

**Resource**

Some micro-service may have a model class that extend to `ActiveResource` on requesting to the other service. 
By following the authenticator structure, all request from service to service required an `Authorization` header.
This can be done by replacing from extending `ActiveResource` to `Volcanic::Authenticator::V1::Resource`

example:
```ruby
# using ActiveResource
class User < ActiveResource::Base
  self.site = "https://vault.aws.local"
end

# using auth-gem 
class User < Volcanic::Authenticator::V1::Resource
  self.site = 'https://vault.aws.local'
end
```



**HTTPRequest**

For non-`ActiveResource`request:

```ruby
Volcanic::Authenticator::V1::HTTPRequest.get('https://vault.aws.local/user')
# support 'get', 'post', 'put', 'patch', 'delete'
```

This class included `HTTParty` gem to it. So it has similar configuration with `HTTParty`

```ruby
response = Volcanic::Authenticator::V1::HTTPRequest.post('https://vault.aws.local/user', body: { name: 'john' }.to_json, headers: { 'Content-Type' => 'application/json' })
response.body
response.code
response.message
response.headers.inspect
```

to predefine base uri:
```ruby
class VaultRequest < Volcanic::Authenticator::V1::HTTPRequest
  # set base uri
  self.base_uri = 'https://vault.aws.local'

  def get_user
     self.class.get('/v1/user')
  end
end

# OR 
VaultRequest.get('/v1/user')
```

**Service**

To create a new service.
```ruby
service = Volcanic::Authenticator::V1::Service.create('name')
```

attributes in principal:
```ruby
service.id
service.name
service.subject_id
service.created_at
service.updated_at
```

To update service name:
```ruby
service.name = 'new_service_name'
service.save
```

To delete service:
```ruby
service.delete
```

To find service by id:
```ruby
service = Volcanic::Authenticator::V1::Service.find_by_id(1)
```

To find service in collections:
```ruby
# similar to Principal.find but without dataset_id args
```
