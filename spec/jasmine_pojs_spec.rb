require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe "POJS jasmine install" do

  before :each do
    temp_dir_before
    Dir::chdir @tmp
    @install_directory = 'pojs-example'
    Dir::mkdir @install_directory
    Dir::chdir @install_directory
  end

  after :each do
    temp_dir_after
  end

  context "when the Jasmine generators are available" do
    before :each do
      `jasmine init`
    end

    it "should find the Jasmine configuration files" do
      File.exists?("spec/javascripts/support/jasmine.yml").should == true
      File.exists?("spec/javascripts/support/jasmine_runner.rb").should == true
      File.exists?("spec/javascripts/support/jasmine_config.rb").should == true
    end

    it "should find the Jasmine example files" do
      File.exists?("public/javascripts/Player.js").should == true
      File.exists?("public/javascripts/Song.js").should == true

      File.exists?("spec/javascripts/PlayerSpec.js").should == true
      File.exists?("spec/javascripts/helpers/SpecHelper.js").should == true

      File.exists?("spec/javascripts/support/jasmine.yml").should == true
      File.exists?("spec/javascripts/support/jasmine_runner.rb").should == true
      File.exists?("spec/javascripts/support/jasmine_config.rb").should == true
    end

    it "should show jasmine rake task" do
      output = `rake -T`
      output.should include("jasmine ")
      output.should include("jasmine:ci")
    end

    it "should successfully run rake jasmine:ci" do
      output = `rake jasmine:ci`
    end

    context "and running with jasmine:ci" do

      before :each do
        @fixture = File.expand_path(File.join(File.dirname(__FILE__), 'fixture'))
        FileUtils.cp File.join(@fixture, 'spec', 'example_spec.js'), "spec/javascripts"
        FileUtils.cp File.join(@fixture, 'spec', 'example_with_syntax_error_spec.js'), "spec/javascripts"
        FileUtils.cp File.join(@fixture, 'src', 'example.js'), "public/javascripts"

        File.exists?("public/javascripts/example.js").should == true
        File.exists?("spec/javascripts/example_spec.js").should == true
        File.exists?("spec/javascripts/example_with_syntax_error_spec.js").should == true
      end

      it "should point a syntax error even with all tests passing" do
        system "rake jasmine:ci &> out.txt"
        File.read("out.txt").should include("Probably a syntax error ocurred in your spec files")
      end

      it "should point a syntax error even with failures" do
        FileUtils.cp File.join(@fixture, 'spec', 'example_with_failure_spec.js'), "spec/javascripts"
        File.exists?("spec/javascripts/example_with_failure_spec.js").should == true

        system "rake jasmine:ci &> out.txt"
        File.read("out.txt").should include("Probably a syntax error ocurred in your spec files")
      end

    end

  end
end