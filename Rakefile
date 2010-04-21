$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")
require "bundler"
Bundler.setup

require 'spec'
require 'spec/rake/spectask'

desc "Run all examples"
Spec::Rake::SpecTask.new('spec') do |t|
  t.spec_files = FileList['spec/**/*.rb']
end

namespace :jasmine do
  require 'spec/jasmine_self_test_config'
  task :server do
    puts "your tests are here:"
    puts "  http://localhost:8888/"

    JasmineSelfTestConfig.new.start_server
  end
end

desc "Run specs via server"
task :jasmine => ['jasmine:server']


namespace :jeweler do

  unless File.exists?('jasmine/lib')
    raise "Jasmine submodule isn't present.  Run git submodule update --init"
  end

  begin
    require "jeweler"
    Jeweler::Tasks.new do |gemspec|
      gemspec.name = "jasmine"
      gemspec.summary = "Jasmine Ruby Runner"
      gemspec.description = "Javascript BDD test framework"
      gemspec.email = "ragaskar@gmail.com"
      gemspec.homepage = "http://github.com/pivotal/jasmine-ruby"
      gemspec.authors = ["Rajan Agaskar", "Christian Williams"]
      gemspec.executables = ["jasmine"]
      gemspec.files = FileList.new('generators/**/**', 'lib/**/**', 'jasmine/lib/**', 'jasmine/contrib/ruby/**', 'tasks/**', 'templates/**')
      gemspec.add_dependency('rspec', '>= 1.1.5')
      gemspec.add_dependency('rack', '>= 1.0.0')
      gemspec.add_dependency('selenium-rc', '>=2.1.0')
      gemspec.add_dependency('selenium-client', '>=1.2.17')
    end
    Jeweler::GemcutterTasks.new
  end
end
