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

jasmine_runner_config = Jasmine::RunnerConfig.new
server = Jasmine::Server.new(jasmine_runner_config.port, Jasmine::Application.app(jasmine_runner_config))
client = Jasmine::SeleniumDriver.new(jasmine_runner_config.browser,
                                     "#{jasmine_runner_config.jasmine_host}:#{jasmine_runner_config.port}/")

t = Thread.new do
  begin
    server.start
  rescue ChildProcess::TimeoutError
  end
  # # ignore bad exits
end
t.abort_on_exception = true
Jasmine::wait_for_listener(jasmine_runner_config.port, "jasmine server")
puts "jasmine server started."

Jasmine::Runners::HTTP.new(Jasmine::RspecFormatter.new(jasmine_runner_config), client).run

