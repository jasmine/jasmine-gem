require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe "Jasmine bug fixes" do
  before :each do
    temp_dir_before
    Dir::chdir @tmp

    @bootstrap = "$:.unshift('#{@root}/lib')"
  end

  after :each do
    temp_dir_after
  end

  module Foo end
  describe "require 'json_pure'" do
    it "should not happen until SeleniumDriver is initialized, which is late enough that it won't conflict with Rails" do
      json_is_defined = `ruby -e "#{@bootstrap}; require 'jasmine'; puts defined?(JSON)"`
      json_is_defined.chomp.should == "nil"
    end

    it "should happen when SeleniumDriver is initialized" do
      json_is_defined = `ruby -e "#{@bootstrap}; require 'jasmine'; Jasmine::SeleniumDriver.new(nil, nil, nil, nil); puts defined?(JSON)"`
      json_is_defined.chomp.should == "constant"
    end

    it "should not happen if another json implementation is already loaded" do
      json_is_defined = `ruby -e "#{@bootstrap}; require 'jasmine'; JSON="123"; Jasmine::SeleniumDriver.new(nil, nil, nil, nil); puts defined?(JSON)"`
      json_is_defined.chomp.should == "constant"
    end
  end
end