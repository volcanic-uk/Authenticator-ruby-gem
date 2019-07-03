
## Group Permission
**Create**

Create a new Group.

```ruby
group = Volcanic::Authenticator::V1::Group.create('group-a', 'description', 1, 2)
group.name # => 'group-a'
group.id # => '1'
group.description # => 'description'
```

**Get all**

get all Groups
```ruby
groups = Volcanic::Authenticator::V1::Group.all
groups[0].id # => 1
groups[0].name # => 'group name'
...
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
Volcanic::Authenticator::V1::Group.new(1).delete

# OR
 
group = Volcanic::Authenticator::V1::Group.find_by_id(1)
group.delete
```