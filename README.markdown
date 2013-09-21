# The Jasmine Gem <a title="Build at Travis CI" href="http://travis-ci.org/#!/pivotal/jasmine-gem"><img src="https://secure.travis-ci.org/pivotal/jasmine-gem.png" /></a>

The [Jasmine](http://github.com/pivotal/jasmine) Ruby Gem is a package of helper code for developing Jasmine projects for Ruby-based web projects (Rails, Sinatra, etc.) or for JavaScript projects where Ruby is a welcome partner. It serves up a project's Jasmine suite in a browser so you can focus on your code instead of manually editing script tags in the Jasmine runner HTML file.

## Contents
This gem contains:

* A small server that builds and executes a Jasmine suite for a project
* A script that sets up a project to use the Jasmine gem's server
* Generators for Ruby on Rails projects (Rails 3 and Rails 4)

You can get all of this by: `gem install jasmine` or by adding Jasmine to your `Gemfile`.

```ruby
group :development, :test do
  gem 'jasmine'
end
```

## Init A Project

To initialize a project for Jasmine

`rails g jasmine:install`
`rails g jasmine:examples`

For any other project (Sinatra, Merb, or something we don't yet know about) use

`jasmine init`

## Usage

Start the Jasmine server:

`rake jasmine`

Point your browser to `localhost:8888`. The suite will run every time this page is re-loaded.

Start Jasmine on a different port:

`rake jasmine JASMINE_PORT=1337`

Point your browser to `localhost:1337`. 

For Continuous Integration environments, add this task to the project build steps:

`rake jasmine:ci`

This uses PhantomJS to load and run the Jasmine suite.

## Configuration

Customize `spec/javascripts/support/jasmine.yml` to enumerate the source files, stylesheets, and spec files you would like the Jasmine runner to include.
You may use dir glob strings.

## Support

Jasmine Mailing list: [jasmine-js@googlegroups.com](mailto:jasmine-js@googlegroups.com)
Twitter: [@jasminebdd](http://twitter.com/jasminebdd)

Please file issues here at Github

Copyright (c) 2008-2013 Pivotal Labs. This software is licensed under the MIT License.
