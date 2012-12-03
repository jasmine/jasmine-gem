source "http://rubygems.org"
gemspec

gem "jasmine-core", :git => "http://github.com/pivotal/jasmine.git", :branch => '2_0'
unless ENV["TRAVIS"]
  group :debug do
    gem 'debugger'
  end
end
