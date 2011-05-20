require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
require 'jasmine_self_test_config'
require 'fileutils'

describe Jasmine::SpecBuilder do
  let :run_jasmine_tests do
    spec_builder = Jasmine::SpecBuilder.new( jasmine_config )
    spec_builder.start
    spec_builder.wait_for_suites_to_finish_running
    spec_builder.stop
  end
  let(:report_dir){File.join(File.dirname(__FILE__), '..', 'tmp', 'reports')}

  context "coverage is not enabled" do
    let :jasmine_config do
      JasmineSelfTestConfig.new
    end

    it "does not create +report_dir+" do
      run_jasmine_tests
      report_dir.should_not exist
    end
  end

  context "coverage is enabled" do
    let :jasmine_config do
      config = JasmineSelfTestConfig.new
      class << config
        def coverage_config
          {
            'enabled'    => true,
            'encoding'   => 'utf-8',
            'temp_dir'   => File.join('tmp', 'src'),
            'report_dir' => File.join('tmp','reports'),
          }
        end

        def simple_config
          {
            'src_files' => ['**/*.js'],
            'helpers'   => ['support/helpers/**/*.js'],
          }
        end
      end
      config
    end
    let(:helper_dir){File.join(jasmine_config.spec_dir, 'support', 'helpers')}
    let(:jscoverage_js) do
      File.join(File.dirname(__FILE__),'..','lib','generators','jasmine','install','templates','spec','javascripts','helpers','jscoverage.js')
    end

    # Helpers are relative to spec_dir, so jasmine won't serve them out of here
    before :each do
      FileUtils.mkdir_p helper_dir
      FileUtils.cp jscoverage_js, helper_dir
      FileUtils.rm_rf File.join(File.dirname(__FILE__), '..', 'tmp')
    end

    after :each do
      # Don't leave the submodule dirty after a test run
      FileUtils.rm File.join(helper_dir, File.basename(jscoverage_js))
      # Clean up tmp
      FileUtils.rm_rf File.join(File.dirname(__FILE__), '..', 'tmp')
    end

    it "copies the jscoverage reports to +report_dir+" do
      run_jasmine_tests

      report_dir.should exist
      %w(   jscoverage.css jscoverage-highlight.css jscoverage.html
            jscoverage-ie.css jscoverage.js jscoverage-throbber.gif ).each do |jscoverage_file|
        File.join(report_dir, jscoverage_file).should exist
      end
    end

    it "computes and saves jscoverage.json" do
      run_jasmine_tests
      json_file = File.join(report_dir, 'jscoverage.json')
      json_file.should exist
      json = JSON.parse( File.read( json_file ))
      json.keys.should == ['src.js']
      json['src.js']['coverage'].should be_a Array
      json['src.js']['source'].should be_a Array
    end

    it "appends jscoverage_isReport = true to jscoverage.js" do
      run_jasmine_tests
      jscoverage_file = File.join(report_dir, 'jscoverage.js')
      jscoverage_file.should exist
      File.read(jscoverage_file).should include "jscoverage_isReport = true"
    end
  end
end
