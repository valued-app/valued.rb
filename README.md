# Ruby Client for [Valued](https://valued.app/)

Events are sent asynchronously to not block your application.

## Using Global State

``` ruby
Valued.connect(token: ENV["VALUED_TOKEN"], project_id: ENV["VALUED_PROJECT"])

# trigger an even without predefined scope
Valued.track("access.user.invite", {
  client_id: account.id,
  user_id: current_user.id,
  invited_user: invited_user.id
})

# Set an execution scope for tracked events
Valued.scope(client_id: account.id, user_id: current_used.id) do
  Valued.track("access.user.signin")
  Valued.track("access.user.invite", invited_user: invited_user.id)
end
```

## Multiple Connection / Avoid Global State

``` ruby
connection = Valued::Connection.new(token: ENV["VALUED_TOKEN"], project_id: ENV["VALUED_PROJECT"])

# trigger an even without predefined scope
connection.track("access.user.invite", {
  client_id: account.id,
  user_id: current_user.id,
  invited_user: invited_user.id
})

# create a scope with predefined data
scope = connection.scope(user_id: current_user.id, account_id: account.id)
scope.track("access.user.signin")
scope.track("access.user.invite", invited_user: invited_user.id)
```