# Chusaku

[![Gem Version](https://badge.fury.io/rb/chusaku.svg)](https://badge.fury.io/rb/chusaku)

Add comments above your Rails actions that look like:

```ruby
# @route GET /waterlilies/:id (waterlily)
def show
  # ...
end

# @route PATCH /waterlilies/:id (waterlily)
# @route PUT /waterlilies/:id (waterlily)
def update
  # ...
end
```

Based on your `routes.rb` file!


## Installation

Add this line to your Rails application's Gemfile:

```ruby
group :development do
  # ...
  gem "chusaku", require: false
  # ...
end
```

And then execute:

```
$ bundle install
```


## Usage

From the root of your Rails application, run:

```
$ bundle exec chusaku
```

Chusaku has some flags available for use as well:

```
$ bundle exec chusaku --help
Usage: chusaku [options]
        --dry-run                    Run without file modifications
        --exit-with-error-on-annotation
                                     Fail if any file was annotated
        --verbose                    Print all annotations
    -v, --version                    Show Chusaku version number and quit
    -h, --help                       Show this help message and quit
```


## Development

Read the blog post explaining how the gem works at a high level:
https://nshki.com/chusaku-a-controller-annotation-gem.

After checking out the repo, run `bin/setup` to install dependencies. Then, run
`bundle exec rake test` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
git commits and tags, and push the `.gem` file to
[rubygems.org](https://rubygems.org).
