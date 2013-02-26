require 'spec_helper'

describe Jasmine::Results do
  describe "#failures" do
    it "should report a failure count" do
      subject = Jasmine::Results.new([failing_raw_result, failing_raw_result])
      subject.failures.size.should == 2

      subject = Jasmine::Results.new([failing_raw_result, passing_raw_result])
      subject.failures.size.should == 1
    end
  end

  describe "#size" do
    it "should report the spec count" do
      subject = Jasmine::Results.new([failing_raw_result, failing_raw_result])
      subject.size.should == 2

      subject = Jasmine::Results.new([failing_raw_result])
      subject.size.should == 1
    end
  end

end

describe Jasmine::Results::Result do
  describe "data accessors" do
    it "delegates to raw results" do
      result = Jasmine::Results::Result.new("status" => "failed")
      result.status.should == "failed"
    end

    it "remaps important camelCase names to snake_case" do
      result = Jasmine::Results::Result.new(failing_raw_result)
      result.full_name.should == "a suite with a failing spec"
    end

    it "exposes failed expectations" do
      result = Jasmine::Results::Result.new(failing_raw_result)

      expectation = result.failed_expectations[0]
      expectation.message.should == "a failure message"
      expectation.stack_trace.should == "a stack trace"
    end
  end
end

