$:.unshift(ENV['JASMINE_GEM_PATH']) if ENV['JASMINE_GEM_PATH'] # for gem testing purposes

require 'rubygems'
require 'jasmine'
if Jasmine::Dependencies.rspec2?
  require 'rspec'
else
  require 'spec'
end

Jasmine.load_configuration_from_yaml

config = Jasmine.config

server = Jasmine::Server.new(config.port, Jasmine::Application.app(config))
driver = Jasmine::SeleniumDriver.new(config.browser, "#{config.host}:#{config.port}/")
t = Thread.new do
  begin
    server.start
  rescue ChildProcess::TimeoutError
  end
  # # ignore bad exits
end
t.abort_on_exception = true
Jasmine::wait_for_listener(config.port, "jasmine server")
puts "jasmine server started."

reporter = Jasmine::Reporters::ApiReporter.new(driver, config.result_batch_size)
raw_results = Jasmine::Runners::HTTP.new(driver, reporter).run
results = Jasmine::Results.new(raw_results)

formatter = Jasmine::Formatters::Console.new(results)
puts formatter.failures
puts formatter.summary

if config.junit_xml
  xml = Jasmine::Formatters::JUnitXml.new(results)
  f = open(File.join(config.junit_xml_location, 'junit_results.xml'), 'w')
  f.puts xml.summary
  f.close()
end