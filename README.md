# Echo360DL

Batch download echo360 public media from url like: `https://echo360.org[.*]/media/:uuid/public`
Require chromium/chrome to be installed.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'echo360_dl'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install echo360_dl

## Usage

```ruby
require "echo360_dl"
cli = Echo360DL::Client.new

urls = %w[
  url1
  ur12
  ...
]

urls.each do |url|
  cli.goto url
  cli.add_task
end

begin
  cli.download_all
rescue
  binding.irb
end

# optional for post checking
binding.irb
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/jitingcn/echo360_dl.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
