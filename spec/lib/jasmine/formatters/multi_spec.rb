require 'spec_helper'

describe Jasmine::Formatters::Multi do
  it "should have all the methods of a formatter" do
    instance_methods = Jasmine::Formatters::Multi.instance_methods - Object.instance_methods
    base_methods = Jasmine::Formatters::Base.instance_methods(false).first
    instance_methods.should include(base_methods)
  end

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
