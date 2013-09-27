require 'spec_helper'

describe Jasmine::Formatters::Multi do
  it "should delegate to the passed in formatters" do
    formatter1 = double(:formatter1)
    formatter2 = double(:formatter2)
    multi = Jasmine::Formatters::Multi.new([formatter1, formatter2])

    formatter1.should_receive(:format)
    formatter2.should_receive(:format)
    multi.format(nil)

    formatter1.should_receive(:done)
    formatter2.should_receive(:done)
    multi.done
  end
end
