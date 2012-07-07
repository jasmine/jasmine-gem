require 'spec_helper'
require 'jasmine_self_test_config'

jasmine_runner_config = Jasmine::RunnerConfig.new(JasmineSelfTestConfig.new)
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
