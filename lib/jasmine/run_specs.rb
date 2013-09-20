$:.unshift(ENV['JASMINE_GEM_PATH']) if ENV['JASMINE_GEM_PATH'] # for gem testing purposes

require 'rubygems'
require 'jasmine'
require 'rspec'

Jasmine.load_configuration_from_yaml

config = Jasmine.config

server = Jasmine::Server.new(config.port, Jasmine::Application.app(config))
t = Thread.new do
  begin
    server.start
  rescue ChildProcess::TimeoutError
  end
  # # ignore bad exits
end
t.abort_on_exception = true
Jasmine::wait_for_listener(config.port, 'jasmine server')
puts 'jasmine server started.'

formatters = config.formatters.map { |formatter_class| formatter_class.new(config) }
runner = config.runner.new(Jasmine::Formatters::Multi.new(formatters), config)
runner.run

exit runner.succeeded? ? 0 : 1
