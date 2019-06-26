
## Group Permission
**Create**

Create a new Group.

```ruby
#
# Group.create(Group_NAME, DESCRIPTION, SERVICE_ID) 
group = Volcanic::Authenticator::V1::Group.create('group-a', 'new Group', 1)

group.name # => 'Group-a'
group.id # => '1'
group.creator_id # => 1
group.description # => 1

```

**Get all**

get/show all Groups
```ruby
Volcanic::Authenticator::V1::Group.all

#  => return an array of Group objects
```

**Find by id**

Get a Group.
```ruby
#
# Group.find_by_id(GROUP_ID)
group =  Volcanic::Authenticator::V1::Group.find_by_id(1)

group.name # => 'Group-a'
group.id # => '1'
group.creator_id # => 1
group.description # => 1
group.active # => true

```

**Update**

Edit/Update a Group.
```ruby
##
# must be in hash format
# attributes :name, :description
attributes = { name: 'Group-b', description: "new description" }
         
##
# Group.update(GROUP_ID, ATTRIBUTES) 
Volcanic::Authenticator::V1::Group.update(1, attributes)
```

**Delete**

Delete a Group.
```ruby
##
# Group.delete(GROUP_ID)
Volcanic::Authenticator::V1::Group.delete(1) 
```