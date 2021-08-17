source 'https://rubygems.org'

gemspec


# during development, do not release
if ENV['CIRCLECI']
  gem 'jasmine-core', :git => 'http://github.com/jasmine/jasmine.git', ref: 'main'
else
  gem 'jasmine-core', :path => '../jasmine'
end

gem 'rack', '>= 2.0'

gem 'mime-types', '< 3.0', platform: [:jruby]

if ENV['RAILS_VERSION'] != 'rails4'
  gem "bundler", ">= 2.1.4"
end
