# Depdump

:construction: Still a work in progress, interfaces may be changed.

A dump tool of ruby class/module dependencies.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'depdump'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install depdump

## Usage

Quick start:

    $ cd my/cool/ruby/project
    $ depdump

Or, specify files and directories.

    $ depdump lib/greate_module.rb app

Then, the dependency graph appeared as a JSON string in stdout.

And some execution warnings are written in `depdump-error.log`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/upinetree/depdump. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Depdump project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/depdump/blob/master/CODE_OF_CONDUCT.md).
