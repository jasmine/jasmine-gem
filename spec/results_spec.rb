require 'spec_helper'

describe Jasmine::Results do
  describe "#failures" do
    it "should report all the failing spec" do
      subject = Jasmine::Results.new([failing_raw_result, failing_raw_result])
      subject.failures.size.should == 2

      subject = Jasmine::Results.new([failing_raw_result, passing_raw_result])
      subject.failures.size.should == 1
    end
  end

  describe "#pending_specs" do
    it "should report all the pending specs" do
      subject = Jasmine::Results.new([pending_raw_result, pending_raw_result])
      subject.pending_specs.size.should == 2

      subject = Jasmine::Results.new([pending_raw_result, passing_raw_result])
      subject.pending_specs.size.should == 1
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
      expectation.stack.should == "a stack trace"
    end

    it "exposes only the last 7 lines of the stack trace" do
      raw_result = failing_raw_result
      raw_result["failedExpectations"][0]["stack"] = "1\n2\n3\n4\n5\n6\n7\n8\n9"

      result = Jasmine::Results::Result.new(raw_result)
      expectation = result.failed_expectations[0].stack
      expectation.should match(/1/)
      expectation.should match(/7/)
      expectation.should_not match(/8/)
      expectation.should_not match(/9/)
    end
  end
end

