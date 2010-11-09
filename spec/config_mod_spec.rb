require 'spec_helper'
describe "Config mod" do
  
  describe "should allow .gitignore style negation (!pattern)" do
    before(:each) do
      @config = Jasmine::Config.new
      Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
      fake_config = Hash.new.stub!(:[]).and_return {|x| ["file1.ext", "!file1.ext", "file2.ext"]}
      @config.stub!(:simple_config).and_return(fake_config)
    end
    
    it "should not contain negated files" do
      @config.src_files.should == [ "file2.ext"]
    end
    
    
  end
  
end