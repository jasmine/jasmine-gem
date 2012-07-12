require 'spec_helper'
require 'jasmine_self_test_config'

jasmine_runner_config = Jasmine::RunnerConfig.new(JasmineSelfTestConfig.new)
spec_builder = Jasmine::SpecBuilder.new(jasmine_runner_config)

should_stop = false

if Jasmine::Dependencies.rspec2?
  RSpec.configuration.after(:suite) do
    spec_builder.stop if should_stop
  end
else
  Spec::Runner.configure do |config|
    config.after(:suite) do
      spec_builder.stop if should_stop
    end
  end
end

spec_builder.start
should_stop = true
spec_builder.declare_suites
