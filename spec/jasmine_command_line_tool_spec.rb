require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

def create_temp_dir
  tmp = File.join(Dir.tmpdir, 'jasmine-gem-test')
  FileUtils.rm_r(tmp, :force => true)
  FileUtils.mkdir(tmp)
  tmp
end

describe "Jasmine command line tool" do
  before :each do
    @old_dir = Dir::pwd
    @tmp = create_temp_dir
    Dir::chdir @tmp
  end

  after :each do
    Dir::chdir @old_dir
  end

  it "should create files on init" do
    Jasmine::CommandLineTool.new.process ["init"]

    my_jasmine_lib = File.expand_path(File.join(File.dirname(__FILE__), "../lib"))
    bootstrap = "$:.unshift('#{my_jasmine_lib}')"

    ci_output = `rake -E \"#{bootstrap}\" --trace jasmine:ci`
    ci_output.should =~ (/[1-9][0-9]* examples, 0 failures/)
  end
end