require 'spec_helper'

describe Jasmine::Runners::ApiReporter do
  let(:driver) { FakeSeleniumDriver.new }
  let(:batch_size) { 3 }
  subject { Jasmine::Runners::ApiReporter.new(driver, batch_size) }

  describe '#started?' do
    it "reflects that Jasmine has started" do
      driver.should_receive(:eval_js).twice.with(Jasmine::Runners::ApiReporter::STARTED_JS).and_call_original

      subject.should_not be_started

      driver.start

      subject.should be_started
    end
  end

  describe '#finished?' do
    it "reflects that Jasmine has finished" do
      driver.should_receive(:eval_js).twice.with(Jasmine::Runners::ApiReporter::FINISHED_JS).and_call_original

      subject.should_not be_finished

      driver.finish

      subject.should be_finished
    end
  end

  describe "#results" do
    it "gets all of the results" do
      driver.should_receive(:eval_js).with("jsApiReporter && jsApiReporter.specResults(0, 3)").and_call_original
      driver.should_receive(:eval_js).with("jsApiReporter && jsApiReporter.specResults(3, 3)").and_call_original

      results = subject.results

      results.size.should == 4
      results[0]['id'].should == 1
      results[1]['id'].should == 2
      results[2]['id'].should == 3
      results[3]['id'].should == 4
    end
  end

end