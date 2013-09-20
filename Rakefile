$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__))
$LOAD_PATH.unshift File.expand_path("#{File.dirname(__FILE__)}/lib")
require 'bundler'
Bundler::GemHelper.install_tasks

require 'jasmine'
require 'rspec'
require 'rspec/core/rake_task'

desc 'Run all examples'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '-t ~performance'
end

desc 'Run performance build'
RSpec::Core::RakeTask.new(:performance_specs) do |t|
  t.pattern = 'spec/**/*_spec.rb'
  t.rspec_opts = '-t performance'
end

task :spec => %w(jasmine:copy_examples_to_gem)

task :default => :spec

namespace :jasmine do
  require 'jasmine-core'
  task :server do
    Jasmine.configure do |config|
      root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
      config.src_dir = File.join(root, 'src')
      config.spec_dir = Jasmine::Core.path
      config.spec_files = lambda { (Jasmine::Core.html_spec_files + Jasmine::Core.core_spec_files).map {|f| File.join(config.spec_dir, f) } }
      config.jasmine_port = ENV['JASMINE_PORT'] || 8888
    end

    config = Jasmine.config

    server = Jasmine::Server.new(config.jasmine_port, Jasmine::Application.app(config))
    server.start

    puts 'your tests are here:'
    puts "  http://localhost:#{config.jasmine_port}/"
  end

  desc 'Copy examples from Jasmine JS to the gem'
  task :copy_examples_to_gem do
    require 'fileutils'

    # copy jasmine's example tree into our generator templates dir
    FileUtils.rm_r('generators/jasmine/templates/jasmine-example', :force => true)
    FileUtils.cp_r(File.join(Jasmine::Core.path, 'example'), 'generators/jasmine/templates/jasmine-example', :preserve => true)
  end
end

desc 'Run specs via server'
task :jasmine => %w(jasmine:server)

