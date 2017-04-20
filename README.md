[![Gem Version](https://badge.fury.io/rb/puttext.svg)](http://badge.fury.io/rb/puttext)
[![Build Status](https://travis-ci.org/mntnorv/puttext.svg)](https://travis-ci.org/mntnorv/puttext)
[![Code Climate](https://codeclimate.com/github/mntnorv/puttext/badges/gpa.svg)](https://codeclimate.com/github/mntnorv/puttext)
[![Test Coverage](https://codeclimate.com/github/mntnorv/puttext/badges/coverage.svg)](https://codeclimate.com/github/mntnorv/puttext/coverage)

# puttext

Put translatable gettext strings from your Ruby code to a `.po` or `.pot` file.

For example, if you have this `translatable.rb` file:
```ruby
puts _('translatable string')
```

You get this output:
```po
#: translatable.rb:1
msgid "translatable string"
msgstr ""
```

## Language support

Supports extracting strings from these types of files:
- Ruby
- Slim

## Installation

Using RubyGems:
```bash
$ gem install puttext
```

Or add it to your `Gemfile` if using Bundler:
```ruby
gem 'puttext', require: false
```

Also, if you want additional language support beyond plain Ruby, install these gems:
- [**slim**](https://github.com/slim-template/slim) for Slim support.


## Usage

Just run the `puttext` command line tool and point it to your Ruby project:
```bash
$ puttext /path/to/your/project
```

### Options

#### `-o`, `--output`

By default `puttext` will output the extracted PO file contents to stdout. You can write the output to a file by specifying the `-o`, `--output` option.

```bash
$ puttext /path/to/your/project -o template.pot
```

## Contributing

Before submitting an Issue or Pull Request always check if your issue is already being discussed or if someone has already submitted a pull request with the feature you want to add. Also, before doing bigger changes, it's always good to discuss the changes you're going to make in an Issue.

### Code style

PutText uses RuboCop (https://github.com/bbatsov/rubocop) to check and enforce code style. Before submitting a pull request, make sure that RuboCop does not find any offenses.

#### Running RuboCop

```bash
$ bundle exec rubocop
```

### Testing

PutText uses RSpec (http://rspec.info/) for testing. Pull requests with Ruby code changes must include RSpec tests that check the new functionality or changed code. Also, make sure that your changes do not break any existing tests.

#### Running RSpec

```bash
$ bundle exec rspec
```
