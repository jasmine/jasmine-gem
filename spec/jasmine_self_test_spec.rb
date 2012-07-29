require 'spec_helper'
require 'jasmine_self_test_config'

jasmine_runner_config = Jasmine::RunnerConfig.new(JasmineSelfTestConfig.new)
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

results_processor = Jasmine::ResultsProcessor.new(jasmine_runner_config)
results = Jasmine::Runners::HTTP.new(client, results_processor).run
formatter = Jasmine::RspecFormatter.new
formatter.format_results(results)
