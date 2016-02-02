# Blockbuster

Managing your VCR cassettes since 2016.

The task of this gem is to take all your VCR cassettes and package them into one `.tar.gz` file
for adding to git or other vcs.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'blockbuster'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install blockbuster

## Usage

#### Minitest example

Given a directory layout of:

```
-- test
   |-- blockbuster_spec.rb
   |-- cassettes
   |   |-- foo.yml
   |   `-- bar.yml
   `-- test_helper.rb
```

In your `test_helper.rb` add

```
manager = Blockbuster.new(test_directory: File.dirname(__FILE__))
manager.rent
```

And then in an after run bock

```
Minitest.after_run do
  manager.return
end
```

If there were changes/additions/deletions to your cassette files a new tar.gz cassette file will be created.

#### Blockbuster::Manager

The manager constructor takes the following options:

```
cassette_directory: string
  Name of directory cassette files are stored.
  Will be stored under the test directory.
  default: 'casssettes'
cassette_file: String
  name of gz cassettes file.
  default: 'vcr_cassettes.tar.gz'
test_directory: String
  path to test directory where cassete file and cassetes will be stored.
  default: 'test'
silent: Boolean
  Silence all output.
  default: false
```

There are 3 public methods

```
manager.rent
manager.setup
```

Extracts all cassettes from `test/vcr_cassettes.tar.gz` into `test/cassetes`

```
manager.rewind?
manager.compare
```

Compares the the files in `test/cassettes` to the files created during setup. Returns `true`
if there are any changes or additions. Returns `false` if they are identical.

```
manager.return
manager.teardown
```

Packages cassete files into `test/vcr_cassettes.tar.gz` if `rewind?` returns true.
Can be called with `force: true` to force it to create the cassete file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/blockbuster. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

