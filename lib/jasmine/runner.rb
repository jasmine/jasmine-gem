$:.unshift(ENV['JASMINE_GEM_PATH']) if ENV['JASMINE_GEM_PATH'] # for gem testing purposes

require 'rubygems'
require 'jasmine'
jasmine_config_overrides = File.expand_path(File.join(Dir.pwd, 'spec', 'javascripts', 'support', 'jasmine_config.rb'))
require jasmine_config_overrides if File.exist?(jasmine_config_overrides)
if Jasmine::Dependencies.rspec2?
  require 'rspec'
else
  require 'spec'
end

jasmine_runner_config = Jasmine::RunnerConfig.new(Jasmine::Config.new)
formatter = Jasmine::RspecFormatter.new(jasmine_runner_config)

should_stop = false

if Jasmine::Dependencies.rspec2?
  RSpec.configuration.after(:suite) do
    formatter.stop if should_stop
  end
else
  Spec::Runner.configure do |config|
    config.after(:suite) do
      formatter.stop if should_stop
    end
  end
end

formatter.start
should_stop = true
formatter.declare_suites
