source 'https://rubygems.org'

gemspec

unless ENV['TRAVIS']
  group :debug do
    gem 'debugger', :platform => :mri
    gem 'ruby-debug', :platform => :jruby
  end
end

gem 'anchorman', :platform => :mri
# during development, do not release
if ENV['TRAVIS']
  gem 'jasmine-core', :git => 'http://github.com/pivotal/jasmine.git'
else
  gem 'jasmine-core', :path => '../jasmine'
end

if ENV['RAILS_VERSION'] == "rails3"
  gem 'rack', '1.4.5'
else
  gem 'rack', '1.5.2'
end

platform :rbx do
  gem 'json'
  gem 'rubysl'
  gem 'racc'
end
