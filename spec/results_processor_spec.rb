require 'spec_helper'

describe Jasmine::ResultsProcessor do
 describe "example locations finder" do
   describe "simple file layout" do
     it "should find groups that start with describe" do     
       spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
       user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
       config = Jasmine::RunnerConfig.new(user_config)
       runner = Jasmine::ResultsProcessor.new(config)
     
       runner.example_locations["example_spec"].should == "spec/fixture/spec/example_spec.js:1: in `it'"
     end
   
     it "should find examples that start with it" do
       spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
       user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
       config = Jasmine::RunnerConfig.new(user_config)
       runner = Jasmine::ResultsProcessor.new(config)
          
       runner.example_locations["example_spec should be here for path loading tests"].should == "spec/fixture/spec/example_spec.js:2: in `it'"
     end
   end
  
   describe "nested groups" do
     it "should contain the name of a nested group" do
       spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
        user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
        config = Jasmine::RunnerConfig.new(user_config)
        runner = Jasmine::ResultsProcessor.new(config)
        
        runner.example_locations["example_spec nested_groups"].should == "spec/fixture/spec/example_spec.js:6: in `it'"
     end
     
     it "should contain the full name of a nested example" do
       spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
        user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
        config = Jasmine::RunnerConfig.new(user_config)
        runner = Jasmine::ResultsProcessor.new(config)

        runner.example_locations["example_spec nested_groups should contain the full name of nested example"].should == "spec/fixture/spec/example_spec.js:7: in `it'"
     end
   end
 end
end
