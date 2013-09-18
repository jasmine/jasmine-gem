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

raw_results = config.runner.call(config)
results = Jasmine::Results.new(raw_results)

config.formatters.each do |formatter_class|
  formatter = formatter_class.new(results)
  formatter.format()
end

exit results.failures.size
