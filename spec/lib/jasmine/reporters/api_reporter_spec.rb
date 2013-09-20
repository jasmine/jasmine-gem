require 'spec_helper'

describe Jasmine::Reporters::ApiReporter do
  let(:driver) { double(:driver) }
  let(:batch_size) { 3 }
  subject { Jasmine::Reporters::ApiReporter.new(driver, batch_size) }

  describe '#started?' do
    it "reflects that Jasmine has started" do
      driver.should_receive(:eval_js).with(Jasmine::Reporters::ApiReporter::STARTED_JS).and_return(false)

      subject.should_not be_started

      driver.should_receive(:eval_js).with(Jasmine::Reporters::ApiReporter::STARTED_JS).and_return(true)

      subject.should be_started
    end
  end

  describe '#finished?' do
    it "reflects that Jasmine has finished" do
      driver.should_receive(:eval_js).with(Jasmine::Reporters::ApiReporter::FINISHED_JS).and_return(false)

      subject.should_not be_finished

      driver.should_receive(:eval_js).with(Jasmine::Reporters::ApiReporter::FINISHED_JS).and_return(true)

      subject.should be_finished
    end
  end

  describe "#results" do
    it "gets all of the results" do
      driver.should_receive(:eval_js).with("return jsApiReporter.specResults(0, 3)").and_return([ {'id' => 1}, {'id' => 2}, {'id' => 3} ])
      driver.should_receive(:eval_js).with("return jsApiReporter.specResults(3, 3)").and_return([ {'id' => 4} ])

      results = subject.results

      results.size.should == 4
      results[0]['id'].should == 1
      results[1]['id'].should == 2
      results[2]['id'].should == 3
      results[3]['id'].should == 4
    end
  end

end
