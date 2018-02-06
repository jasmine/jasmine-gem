To test changes to the jasmine-gem:

* You need to have the [jasmine project](https://github.com/jasmine/jasmine) checked out in `../jasmine`
* Export RAILS_VERSION as either "pojs" (Plain Old JavaScript -- IE, no rails bindings), or "rails4" to test environments other than Rails 5.
* Delete `Gemfile.lock`
* Clear out your current gemset
* exec a `bundle install`
* `rake` until specs are green
* Repeat
* Check in
