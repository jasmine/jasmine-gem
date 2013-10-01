require 'spec_helper'

describe "POJS jasmine install" do

  before :each do
    temp_dir_before
    Dir::chdir @tmp
    @install_directory = 'pojs-example'
    Dir::mkdir @install_directory
    Dir::chdir @install_directory

    `jasmine init`
    `jasmine examples`
  end

  after :each do
    temp_dir_after
  end

  it "should find the Jasmine configuration files" do
    File.exists?("spec/javascripts/support/jasmine.yml").should == true
  end

  it "should find the Jasmine example files" do
    File.exists?("public/javascripts/jasmine_examples/Player.js").should == true
    File.exists?("public/javascripts/jasmine_examples/Song.js").should == true

    File.exists?("spec/javascripts/jasmine_examples/PlayerSpec.js").should == true
    File.exists?("spec/javascripts/helpers/jasmine_examples/SpecHelper.js").should == true

    File.exists?("spec/javascripts/support/jasmine.yml").should == true
  end

  it "should show jasmine rake task" do
    output = `rake -T`
    output.should include("jasmine ")
    output.should include("jasmine:ci")
  end

  it "should successfully run rake jasmine:ci" do
    output = `rake jasmine:ci`
    output.should =~ (/[1-9]\d* specs, 0 failures/)
  end

  it "should raise an error when jasmine.yml cannot be found" do
    config_path = 'some/thing/that/doesnt/exist'
    output = `rake jasmine:ci JASMINE_CONFIG_PATH=#{config_path}`
    $?.should_not be_success
    output.should =~ /Unable to load jasmine config from #{config_path}/
  end

  it "rake jasmine:ci returns proper exit code when the runner raises" do
    failing_runner = File.join('spec', 'javascripts', 'support', 'failing_runner.rb')
    failing_yaml = custom_jasmine_config('raises_exception') do |config|
      config['spec_helper'] = failing_runner
    end

    FileUtils.cp(File.join(@root, 'spec', 'fixture', 'failing_runner.rb'), failing_runner)

    `rake jasmine:ci JASMINE_CONFIG_PATH=#{failing_yaml}`
    $?.should_not be_success
  end
end
