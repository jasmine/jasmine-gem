source "http://rubygems.org"
gemspec

unless ENV["TRAVIS"]
  group :debug do
    gem 'debugger'
  end
end


# during development, do not release
if ENV["TRAVIS"]
  gem "jasmine-core", :git => "http://github.com/pivotal/jasmine.git"
else
  gem "jasmine-core", :path => "/Users/pivotal/workspace/jasmine"
end
