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

Optionally, ignore your cassettes in git and make sure to include the tar.gz file:

```
# .gitignore

test/cassettes
!test/vcr_cassettes.tar.gz
```

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
require 'blockbuster'

manager = Blockbuster::Manager.new do |c|
  c.test_directory = File.dirname(__FILE__)
  c.silent = false
end

# Alternatively you can pass Blockbuster::Manager.new a Blockbuster::Configuration object.  But do not do both.  The block will win if you attempt to do both.  To be clear, passing a configuration as an argument AND additionally providing a block isn't destructive, it just has no purpose.  Pick one or the other.

manager.rent
```

And then in an after run bock

```
Minitest.after_run do
  manager.drop_off
end
```

If there were changes/additions/deletions to your cassette files a new tar.gz cassette file will be created.

#### Blockbuster::Configuration

The configuration constructor takes the following options:

```
cassette_directory: String
  Name of directory cassette files are stored.
  Will be stored under the test directory.
  default: 'casssettes'
master_tar_file: String
  name of gz cassettes file.
  default: 'vcr_cassettes.tar.gz'
test_directory: String
  path to test directory where cassete file and cassetes will be stored.
  default: 'test'
silent: Boolean
  Silence all output.
  default: false
wipe_cassette_dir: Boolean
  If true, will wipe the existing cassette directory when `rent` is called.
  default: false
enable_deltas: Boolean (more on this below)
  Toggle the Delta feature
  default: false
delta_directory: String
  Name of the directory to store deltas (relative to test_directory)
  default: 'deltas'
current_delta_name: String
  Field that names the current delta
  default: 'current_delta.tar.gz'
```

These are all read-only attributes with the exception of `silent`. This is writeable so that one can suppress output
on setup but see output about new/changed cassettes upon `drop_off`.

There are 3 public methods

```
manager.rent
manager.setup
```

Extracts all cassettes from `test/vcr_cassettes.tar.gz` into `test/cassetes`
directory. To wipe the existing directory before extracting cassettes
initialize the manager with `wipe_cassette_dir: true`.

```
manager.rewind?
```

Compares the the files in `test/cassettes` to the files created during setup. Returns `true`
if there are any changes or additions. Returns `false` if they are identical.

```
manager.drop_off
manager.teardown
```

Packages cassete files into `test/vcr_cassettes.tar.gz` if `rewind?` returns true.
Can be called with `force: true` to force it to create the cassete file.

#### Recreating a cassette file

If you are using automatic re-recording of cassettes Blockbuster will see the changes and create a new package.
To skip the cassete extraction and use the existing local cassettes you can run your tests with `VCR_MODE=local`

```
VCR_MODE=local rake test
```

You can remove a single existing cassette and run in local mode and VCR will re-record that cassette and Blockbuster will
package a new cassettes file.

#### Removing or renaming a cassette file

If you rename a cassette or need to delete one from the archive you need to do the following:

* Run your test suite so that you have an up-to-date cassette directory
* Do the work to rename test/cassette etc
* Run tests (even that single test) with `VCR_MODE=local`

#### Re-record all cassettes

```
> rm -r test/cassettes
> rm test/vcr_cassettes.tar.gz
> rake test
```

### Delta feature (*Experimental*)

If you are working on a project that requires a lot of re-recording, or is in active development with HTTP interactions to different systems and multiple developers working on the project, the benefits of Blockbuster degrade quite quickly.  Merge conflicts happen very frequently since all cassettes are stored in one file, and the only resolution is to re-record everything. 

This is why deltas were built.  The idea is inspired by Sphinx's delta index system.  The idea is to add changes or creations to delta files, and not a master file.  In the typical git branching workflow, this would work as follows:

- If no master file exists, one is generated the first time someone utilizes blockbuster.
- current_delta_name is set by dynamically retrieving the git branch name (This git-branch retrieval is the responsibility of the application to configure)
- as long as a master file exists, Blockbuster will only add changes to a new tarball.
- once you've switched to a new branch (presumably you've gotten your branch merged into master), Blockbuster stops writing to that delta, and only applies changes to a new delta based off the new branch name.
- The delta file names include a timestamp, based on when the file was packaged.  This allows Blockbuster to use best-effort sorting to load in all delta files.
- Blockbuster maintains an in-memory datastore of files and their last checksums.  To build this, Blockbuster extracts files from all available tarballs in a sorted order.  The order is always Master first, and then delta files sorted by filename, which for all intents and purposes is based on time of creation (since the name includes a timestamp).  This means that if more than one tarball contains the exact same file, the checksum in the datastore will come from the last file in the sort that contains it.
- This allows conflicts to become far less possible.  Additionally, even if a conflict does occur, resolving the conflict becomes much easier, as the conflict will be isolated to the changes you are actively working on.
- Deletions aren't managed by deltas.  This is because we want to maintain the principle of never touching any other tarball other than master or the the current delta.  To actually delete a file, we'd have to remove it from any tarball it exists in.  This isn't worth the advantage of the guarantee of leaving existing deltas alone.  In the end, regenerating a Master file will resolve deleted files.
- Regenerating a new Master file is actually relatively simple.  The only mechanism required to have Blockbuster do this automatically is to simply delete the existing Master file.  It is additionally currently the responsibility of the application to remove deltas when regenerating a new master file.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/blockbuster. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

