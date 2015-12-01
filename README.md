# Refile::Postgres

A PostgreSQL backend for [Refile](https://github.com/elabs/refile).

[![Build Status](https://travis-ci.org/krists/refile-postgres.svg?branch=master)](https://travis-ci.org/krists/refile-postgres)
[![Code Climate](https://codeclimate.com/github/krists/refile-postgres/badges/gpa.svg)](https://codeclimate.com/github/krists/refile-postgres)
[![Test Coverage](https://codeclimate.com/github/krists/refile-postgres/badges/coverage.svg)](https://codeclimate.com/github/krists/refile-postgres/coverage)

## Why?

* You want to store all your data in one place to simplify backups and replication
* ACID

## Take into account

* Gem is developed and tested using Postgresql 9.3, Ruby 2.1 and ActiveRecord 4.x. It might work with earlier versions.
* Performance hit storing files in database
* Higher memory requirements for database
* Backups can take significantly longer

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'refile-postgres'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install refile-postgres

## Usage with Rails

Generate migration for table were to store list of attachments.

    $ rails g refile:postgres:migration

Run the migrations

    $ rake db:migrate

Generate initializer and set Refile::Postgres as `store` backend.

    $ rails g refile:postgres:initializer

## Contributing

1. Fork it ( https://github.com/krists/refile-postgres/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
