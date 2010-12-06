require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

unless rails3?

  describe "A Rails 2 app" do

    before :each do
      temp_dir_before
      Dir::chdir @tmp
      `rails _2.3.8_ rails-example`
      Dir::chdir 'rails-example'
    end

    after :each do
      temp_dir_after
    end

    context "before Jasmine has been installed" do

      it "should not the jasmine:install generator" do
        output = `./script/generate --help`
        output.should_not include('jasmine:install')
      end

      it "should not show jasmine:install help" do
        output = `cd rails-example && rails g`
        output.should_not include('This will create')
      end

      it "should not show jasmine rake task" do
        output = `cd rails-example && rake -T`
        output.should_not include("jasmine ")
      end

      it "should not show jasmine:ci rake task" do
        output = `cd rails-example && rake -T`
        output.should_not include("jasmine:ci")
      end

    end

    context "when Jasmine has been installed" do
      before :each do
        `mkdir -p lib/generators && cp -R #{@root}/generators/jasmine rails-example/lib/generators`
        `./script/generate jasmine_rails`
      end

      it "should show the jasmine:install " do
        output = `./script/generate --help`
        output.should include("Lib: jasmine_rails")
      end

      it "should show jasmine:install help" do
        output = `./script/generate jasmine_rails --help`

        output.should include("Usage: ./script/generate jasmine_rails")
      end

      it "should find the jasmine spec files" do
        output = `./script/generate jasmine`

        File.exists?("spec/javascripts/helpers/.gitkeep").should == true
        File.exists?("spec/javascripts/support/jasmine.yml").should == true

        File.exists?("spec/javascripts/support/jasmine_runner.rb").should == true
        File.exists?("spec/javascripts/support/jasmine_config.rb").should == true
      end

      it "should show jasmine rake task" do
        output = `rake -T`
        output.should include("jasmine ")
      end

      it "should show jasmine:ci rake task" do
        output = `rake -T`
        output.should include("jasmine:ci")
      end
    end
  end
end
