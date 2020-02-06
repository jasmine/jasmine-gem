source 'https://rubygems.org'

gemspec

gem 'anchorman', :platform => :mri

# during development, do not release
if ENV['TRAVIS']
  gem 'jasmine-core', :git => 'http://github.com/jasmine/jasmine.git'
else
  gem 'jasmine-core', :path => '../jasmine'
end

if ENV['RAILS_VERSION'] == "rails4"
  gem 'rack', '~> 1.6.0'
elsif ENV['RAILS_VERSION'] == "pojs"
  gem 'rack', '< 2.0'
else
  gem 'rack', '>= 2.0'
end

gem 'mime-types', '< 3.0', platform: [:jruby]

if ENV['RAILS_VERSION'] != 'rails4'
  gem "bundler", "~> 2.1"
end
