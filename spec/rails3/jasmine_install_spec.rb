require "spec_helper"

describe "A Rails 3 app" do

  context "when Jasmine has been required" do
    it "should show the Jasmine generators" do
      output = `rails g`
      output.should include("jasmine:install")
      output.should include("jasmine:examples")
    end

    it "should show jasmine:install help" do
			pending
      output = `rails g jasmine:install --help`
      output.should include("rails generate jasmine:install")
    end

    it "should have the jasmine rake task" do
			pending
      output = `rake -T`
      output.should include("jasmine ")
    end

    it "should have the jasmine:ci rake task" do
			pending
      output = `rake -T`
      output.should include("jasmine:ci")
    end

    context "and then installed" do
      before :each do
        @output = `rails g jasmine:install`
      end

      it "should have the Jasmine config files" do
				pending
        @output.should include("create")

        File.exists?("spec/javascripts/helpers/.gitkeep").should == true
        File.exists?("spec/javascripts/support/jasmine.yml").should == true
        File.exists?("spec/javascripts/support/jasmine_runner.rb").should == true
        File.exists?("spec/javascripts/support/jasmine_config.rb").should == true
      end
    end

    context "and the jasmine examples have been installed" do
      it "should find the Jasmine example files" do
				pending
        output = `rails g jasmine:examples`
        output.should include("create")

        File.exists?("public/javascripts/jasmine_examples/Player.js").should == true
        File.exists?("public/javascripts/jasmine_examples/Song.js").should == true

        File.exists?("spec/javascripts/jasmine_examples/PlayerSpec.js").should == true
        File.exists?("spec/javascripts/helpers/SpecHelper.js").should == true
      end
    end
  end
end
