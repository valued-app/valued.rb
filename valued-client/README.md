# Valued Ruby client

## Simple usage

You can create a `Valued::Client` instance and call `action`, `page_view`, `sync` etc directly on the client.

``` ruby
require "valued"

# Get the token for authentication.
token = ENV.fetch("VALUED_TOKEN") # or wherever you store credentials

# Create a client
client = Valued::Client.new(token)

# Record a page view event for the user with the id 123
client.page_view("https://big.company.com/learn/to/waltz", "user.id" => 123)

# Record an action
client.action("report.generated", {
  customer: { id: 12 },
  user: { id: 123 },
  attributes: { format: :pdf }
})

# Sync user data
client.sync_user({
  id: 123,
  name: "Josh Kalderimis",
  email: "josh@valued.app",
  location: { country: "NZ", region: "Wellington" }
})
```

## Incremental scope building

You can use `Valued::Scope` to build up data incrementally:

``` ruby
scope = Valued::Scope.new(client)
scope["user.id"] = 123

# user nagivates to customer with id 12
scope.with("customer.id" => 12) do
  scope.page_view("https://big.company.com/reports/12")
  scope.action("report.generated")
end

# trigger an action without a customer
scope.page_view("https://big.company.com/profile")
scope.action("profile.updated")
```

This is also handy for building up sync data:

``` ruby
scope.user = {
  id: 42, name: "Arthur Dent", email: "sandwich-maker@example.com"
}

scope.customer = {
  id: 1, name: "BBC Radio"
}

scope.sync
```

## Global scope

If you are in an environment that makes sharing global scope easier than explicitely passing around scope, like a Rails application, you can use one globally shared Client instance and a thread-local scope directly via the `Valued` module:

``` ruby
Valued.connect(token)

# Wrap this in a scope so we don't leak a user id.
Valued.scope do
  Valued["user.id"] = 123

  # user nagivates to customer with id 12
  Valued.with("customer.id" => 12) do
    Valued.page_view("https://big.company.com/reports/12")
    Valued.action("report.generated")
  end

  # trigger an action without a customer
  Valued.page_view("https://big.company.com/profile")
  Valued.action("profile.updated")
end
```

## Object mapping

In the examples above, you have to construct the data hashes for users and similar objects yourself when interacting with Valued. Sometimes it would be nice if you could hand your own user and customer objects to `valued-client`:

``` ruby
Valued.action("profile.updated", user: User.current)
```

You have two options to do so.

### Option 1: Define `to_valued_data`

``` ruby
# Assuming this is your user model
class User
  attr_accessor :name, :email, :id
  def to_valued_data = { name: name, email: email, id: id }
end
```

### Option 2: Registereing a converter

This option is handy if you want to keep your Valued logic out of your models, or if you want to create logic for objects outside your control:

``` ruby
Valued::Data.register(User) do |user|
  { id: user.id, name: user.name, email: user.email }
end
```

### Nested objects

Imagine users would have a nested location object. You could handle this in the user conversion logic:

``` ruby
Valued::Data.register(User) do |user|
  { id: user.id, locaion: { country:  user.location.country, region: user.region }}
end
```

However, you would need to repeat this logic for customers as well. Instead, you can register a converter for your location objects:

``` ruby
Valued::Data.register(User) {{ id: _1.id, location: _1.location }}
Valued::Data.register(Location) {{ country: _1.country, region: _1.region }}
```

## Known issues

This gem is incompatible with the [valued](https://rubygems.org/gems/valued) gem.