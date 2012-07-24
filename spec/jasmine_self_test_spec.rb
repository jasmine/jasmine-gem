require 'spec_helper'
require 'jasmine_self_test_config'

jasmine_runner_config = Jasmine::RunnerConfig.new
Jasmine::Runners::Selenium.new(Jasmine::RspecFormatter.new(jasmine_runner_config), jasmine_runner_config)
