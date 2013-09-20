require 'spec_helper'
require 'fileutils'


describe "Phantom JS Runner performance/integration suite", :performance => true do
  before :each do
    temp_dir_before
    Dir::chdir @tmp
  end

  after :each do
    temp_dir_after
  end

  it 'handles deeply nested/large test suites' do
    Jasmine::CommandLineTool.new.process ['init']

    my_jasmine_lib = File.expand_path(File.join(@root, 'lib'))
    bootstrap = "$:.unshift('#{my_jasmine_lib}')"

    FileUtils.cp(File.join(@root, 'spec', 'fixture', 'large_test_suite_spec.js'), File.join(@tmp, 'spec', 'javascripts'))

    ENV['JASMINE_GEM_PATH'] = "#{@root}/lib"
    ci_output = `rake -E "#{bootstrap}" --trace jasmine:ci`
    ci_output.should =~ (/[1-9][0-9]* specs, \d+ failures/)
  end

end
