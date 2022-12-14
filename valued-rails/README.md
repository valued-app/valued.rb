# Valued Rails plugin

A Rails plugin for sending events to [Valued](https://valued.app).

This library:
* Makes it easy to set up valued-client for your Rails project.
* Gives you tools to keep your event tracking logic separate from your business logic.
* Includes a generator to get you set up.
* Only depends on Rails itself and valued-client (which in turn only depends on concurrent-ruby, which Rails also depends on).
* Is well tested.
* Is considered thread-safe and compatible with all common concurrency models (multi-threading, forking, actors, event loops, etc).

**Note:** This plugin isn't stricly necessary. You can use [valued-client](https://github.com/valued-app/valued.rb/tree/main/valued-client#readme) directly in your Rails application. This does leave separation of concern and setup up to you.