require 'spec_helper'

describe Jasmine::Runners::HTTP do
  let(:driver) { FakeSeleniumDriver.new }
  let(:batch_size) { 3 }
  let(:reporter) { Jasmine::Runners::ApiReporter.new(driver, batch_size) }
  subject { Jasmine::Runners::HTTP.new(driver, reporter) }

  describe '#run' do

    it "gets the results from the Jasmine HTML page" do
      driver.should_receive(:connect)
      driver.should_receive(:disconnect)
      reporter.should_receive(:results).and_call_original
      reporter.stub(:started?).and_return(true)
      reporter.stub(:finished?).and_return(true)

      results = subject.run
      results.size.should == 4
    end
  end
end