
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