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
   
   
   describe "groups and examples that use return function" do
     it "should contain a group that uses JS return function" do
        spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
        user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
        config = Jasmine::RunnerConfig.new(user_config)
        runner = Jasmine::ResultsProcessor.new(config)

        runner.example_locations["return example_spec"].should == "spec/fixture/spec/example_spec.js:21: in `it'"
     end
     
     it "should contain an example that uses JS return function" do
       spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
       user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
       config = Jasmine::RunnerConfig.new(user_config)
       runner = Jasmine::ResultsProcessor.new(config)

       runner.example_locations["return example_spec should have example name with return upfront"].should == "spec/fixture/spec/example_spec.js:22: in `it'"       
     end
   end
   
   describe "context" do
     describe "nested context" do
       it "should contain example_location for context in nested in a group" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
         user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
         config = Jasmine::RunnerConfig.new(user_config)
         runner = Jasmine::ResultsProcessor.new(config)

         runner.example_locations["example_spec context group"].should == "spec/fixture/spec/example_spec.js:12: in `it'"
       end
              
       it "should contain example_location for group in nested context" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
         user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
         config = Jasmine::RunnerConfig.new(user_config)
         runner = Jasmine::ResultsProcessor.new(config)

         runner.example_locations["example_spec context group nested group in context"].should == "spec/fixture/spec/example_spec.js:13: in `it'"
       end
       
       it "should contain example_location for nested context spec" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
         user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
         config = Jasmine::RunnerConfig.new(user_config)
         runner = Jasmine::ResultsProcessor.new(config)

         runner.example_locations["example_spec context group nested group in context should be here for nested context"].should == "spec/fixture/spec/example_spec.js:14: in `it'"
       end       
     end
     
     describe "return context" do 
       it "should have context example_location for return context function" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
          user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
          config = Jasmine::RunnerConfig.new(user_config)
          runner = Jasmine::ResultsProcessor.new(config)

          runner.example_locations["return example_spec return context"].should == "spec/fixture/spec/example_spec.js:26: in `it'"         
       end
       
       it "should have a group example_location for return context function" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
          user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
          config = Jasmine::RunnerConfig.new(user_config)
          runner = Jasmine::ResultsProcessor.new(config)

          runner.example_locations["return example_spec return context group inside return context"].should == "spec/fixture/spec/example_spec.js:27: in `it'"
       end

       it "should have an example_location for spec in return function" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
         user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
         config = Jasmine::RunnerConfig.new(user_config)
         runner = Jasmine::ResultsProcessor.new(config)

         runner.example_locations["return example_spec return context group inside return context should be here for nested context with return"].should == "spec/fixture/spec/example_spec.js:28: in `it'"
       end 
     end
     
     describe("root context") do
       it "should have a example_location for root context" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
         user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
         config = Jasmine::RunnerConfig.new(user_config)
         runner = Jasmine::ResultsProcessor.new(config)

         runner.example_locations["root context"].should == "spec/fixture/spec/example_spec.js:35: in `it'"
       end

       it "should have a group example_location for root context" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
         user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
         config = Jasmine::RunnerConfig.new(user_config)
         runner = Jasmine::ResultsProcessor.new(config)

         runner.example_locations["root context nested_group in context"].should == "spec/fixture/spec/example_spec.js:36: in `it'"
       end

       it "should have an example_location for spec for root context" do
         spec_files_full_paths = ['spec/fixture/spec/example_spec.js']
         user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
         config = Jasmine::RunnerConfig.new(user_config)
         runner = Jasmine::ResultsProcessor.new(config)

         runner.example_locations["root context nested_group in context spec in context"].should == "spec/fixture/spec/example_spec.js:37: in `it'"
       end
     end
   end
 end
end
