class JasmineGenerator < Rails::Generator::Base
  def manifest
    m = ::Rails::Generator::Manifest.new

    m.directory "public/javascripts"
    m.file "jasmine-example/src/Player.js", "public/javascripts/Player.js"
    m.file "jasmine-example/src/Song.js", "public/javascripts/Song.js"

    m.directory "spec/javascripts"
    m.file "jasmine-example/spec/PlayerSpec.js", "spec/javascripts/PlayerSpec.js"

    m.directory "spec/javascripts/helpers"
    m.file "jasmine-example/spec/SpecHelper.js", "spec/javascripts/helpers/SpecHelper.js"

    m.directory "spec/javascripts/support"
    m.file "spec/javascripts/support/jasmine-rails.yml", "spec/javascripts/support/jasmine.yml"
    
    m.directory "spec/javascripts/support/reporters"
    m.file "spec/javascripts/support/reporters/jasmine-reporter.js", "spec/javascripts/support/reporters/jasmine-reporter.js"

    m.readme "INSTALL"

    m.directory "lib/tasks"
    m.file "lib/tasks/jasmine.rake", "lib/tasks/jasmine.rake"
    m
  end

end
