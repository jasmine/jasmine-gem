require 'spec_helper'

describe Jasmine::Formatters::Console do
  describe "#failures" do
    it "shows the failure messages" do
      results = OpenStruct.new(:size => 2, :failures => [failing_result, failing_result])
      subject = Jasmine::Formatters::Console.new(results)

      subject.failures.should match(/a suite with a failing spec/)
      subject.failures.should match(/a failure message/)
      subject.failures.should match(/a stack trace/)
    end
  end

  describe "#summary" do
    describe "when the full suite passes" do
      it "shows the spec counts" do
        results = OpenStruct.new(:size => 1, :failures => [])
        subject = Jasmine::Formatters::Console.new(results)

        subject.summary.should match(/1 spec/)
        subject.summary.should match(/0 failures/)
      end

      it "shows the spec counts (pluralized)" do
        results = OpenStruct.new(:size => 2, :failures => [])
        subject = Jasmine::Formatters::Console.new(results)

        subject.summary.should match(/2 specs/)
        subject.summary.should match(/0 failures/)
      end
    end

    describe "when there are failures" do
      it "shows the spec counts" do
        results = OpenStruct.new(:size => 2, :failures => [failing_result])
        subject = Jasmine::Formatters::Console.new(results)

        subject.summary.should match(/2 specs/)
        subject.summary.should match(/1 failure/)
      end

      it "shows the spec counts (pluralized)" do
        results = OpenStruct.new(:size => 2, :failures => [failing_result, failing_result])
        subject = Jasmine::Formatters::Console.new(results)

        subject.summary.should match(/2 specs/)
        subject.summary.should match(/2 failures/)
      end
    end
  end

  def failing_result
    OpenStruct.new(:full_name => "a suite with a failing spec", :failed_expectations => [
        OpenStruct.new(:message => "a failure message", :stack_trace => "a stack trace")
    ])
  end

  def passing_result
    OpenStruct.new(passing_raw_result)
  end
end
