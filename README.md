# Livecal

Livecal processes ical files and translates them into calendars with events listed as they're actually scheduled (i.e. recurring events are provided for each instance that they occur, not just the single piece of information that they're stored as in an ical file).

## Usage

```ruby
# You must provide from/to (otherwise endless recurring events will continue
# forever). The example here is the next 24 hours, but you can use whatever
# frame of time you like.
)
calendars = Livecal.from_string(
  contents_of_an_ical_file,
  from: Time.now,
  to: (Time.now + 86_400)
)

calendars.each do |calendar|
  calendar.events.each do |event|
    puts event.summary, event.starts_at, event.ends_at
  end
end

# Also:
calendars = Livecal.from_url(
  "http://example.com/calendar.ics",
  from: Time.now,
  to: (Time.now + 86_400)
)
# And:
calendars = Livecal.from_file(
  "/path/to/my-calendars.ics",
  from: Time.now,
  to: (Time.now + 86_400)
)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem "livecal"
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install livecal

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/pat/livecal. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/pat/livecal/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [Hippocratic License](https://firstdonoharm.dev).

## Code of Conduct

Everyone interacting in the Livecal project is expected to follow the [code of conduct](https://github.com/pat/livecal/blob/master/CODE_OF_CONDUCT.md).
