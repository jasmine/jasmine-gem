At the moment we don't have an automated way to test the Jasmine Gem in both configurations: Rails 2 / RSpec 1.x & Rails 3 / RSpec 2.

So here are the manual steps:

* Edit jasmine.gemspec and uncomment the lines for Rails 2, comment out the lines for Rails 3
* Delete `Gemfile.lock`
* exec a `bundle install`
* `rake` until specs are green
* Repeat with the Rails 3 development gems
* Repeat again with the Rails 2 development gems
* Check in
