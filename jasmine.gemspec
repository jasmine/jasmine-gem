# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "jasmine/version"

Gem::Specification.new do |s|
  s.name               = %q{jasmine}
  s.version            = Jasmine::VERSION
  s.platform           = Gem::Platform::RUBY

  s.authors            = ["Rajan Agaskar", "Christian Williams", "Davis Frank"]
  s.summary            = %q{JavaScript BDD framework}
  s.description        = %q{Test your JavaScript without any framework dependencies, in any environment, and with a nice descriptive syntax.}
  s.email              = %q{jasmine-js@googlegroups.com}
  s.homepage           = "http://pivotal.github.com/jasmine"

  s.files              = `git ls-files`.split("\n")
  s.test_files         = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables        = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.default_executable = %q{jasmine}
  s.require_paths      = ["lib"]
  s.rdoc_options       = ["--charset=UTF-8"]

  s.add_dependency 'json_pure', '~>1.4.3'
  s.add_dependency 'selenium-rc', '>= 2.2.1'
  s.add_dependency 'selenium-client', '>= 1.2.18'

  if ENV['RAILS_ENV'] == 'rails2'
    # for development & test of Rails 2 Generators
    s.add_development_dependency 'rspec', '1.3.1'
    s.add_development_dependency 'rails', '2.3.10'
    s.add_development_dependency 'rack', '1.1'
  else
    # for development & test of Rails 3 Generators
    s.add_development_dependency 'rspec', '>= 2.0'
    s.add_development_dependency 'rails', '> 3.0.2'
    s.add_development_dependency 'rack', '>= 1.2.1'
  end

  s.add_development_dependency 'rack-test'
  s.add_development_dependency 'gem-release'
end