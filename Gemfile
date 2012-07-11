source "http://rubygems.org"
gemspec

#bundle fails on the rspec gemspec requirement without this line
gem 'rspec', '< 2.11'

unless ENV["TRAVIS"]
  group :debug do
    gem 'debugger'
  end
end
