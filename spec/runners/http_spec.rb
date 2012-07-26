require 'spec_helper'

describe Jasmine::Runners::HTTP do
  describe "running suites" do
    it "should create a new SeleniumDriver" do
      Jasmine.stub(:find_unused_port).and_return(1234)
      Jasmine::SeleniumDriver.should_receive(:new).with('firefox', 'http://localhost:1234/') { double(:driver).as_null_object }
      Jasmine::Server.stub(:new) { double(:server).as_null_object }
      Jasmine::Application.stub(:app) { double(:app).as_null_object }
      Jasmine.stub(:wait_for_listener).and_return(true)
      Jasmine::Runners::HTTP.new(double(:formatter).as_null_object, double(:config)).run
    end
  end
end
