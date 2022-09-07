# Valued Ruby SDK

This repository contains two separate gems:

* [valued-client](valued-client) – a general purpose Ruby client for Valued.
* [valued-rails](valued-rails) – a Rails plugin for Valued.

In addition, there is a simple Sinatra application in [dummy-api](dummy-api) that can be used as an endpoint to point client libraries to.

## Development

Task                         | Command
-----------------------------|---------------------
Installing dependencies      | `bundle install`
Running test                 | `rake test`
Generating API documentation | `rake docs`

You can also run both tasks combined with `rake`. These will generate a `docs` and a `coverage` directory.


## Using Gems straight from GitHub

If you want to use more than one of the gems in this repository directly from the main branch, you can do so by adding the following to your Gemfile:

``` ruby
source "https://rubygems.org"

github "valued-app/valued.rb" do
  gem "valued-client"
  gem "valued-rails"
end
```