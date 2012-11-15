require 'spec_helper'
require 'selenium-webdriver'

describe Jasmine::RunnerConfig do
  describe "css_files" do
    it "should return the jasmine stylesheets and any user defined stylesheets" do
      jasmine_stylesheets = ['some/css/file']
      user_stylesheets = ['some/user/file']
      user_config = double("config", :jasmine_stylesheets => jasmine_stylesheets, :user_stylesheets => user_stylesheets)
      Jasmine::RunnerConfig.new(user_config).css_files.should == jasmine_stylesheets + user_stylesheets
    end
  end

  describe "jasmine_files" do
    it "should return the jasmine files from the config" do
      jasmine_files = ['some/file']
      user_config = double('config', :jasmine_javascripts => jasmine_files)
      Jasmine::RunnerConfig.new(user_config).jasmine_files.should == jasmine_files
    end
  end

  describe "reporters_files" do
    it "should return the user reporter files from the config" do
      reporters_files = ['some/file']
      user_config = double('config', :reporters_files => reporters_files)
      Jasmine::RunnerConfig.new(user_config).reporters_files.should == reporters_files
    end
  end

  describe "reporters_path" do
    it "should return the user reporters_path from the config" do
      reporters_path = ['some/path']
      user_config = double('config', :reporters_path => reporters_path)
      Jasmine::RunnerConfig.new(user_config).reporters_path.should == reporters_path
    end
  end

  describe "reporters_dir" do
    it "should return the user reporters_dir from the config" do
      reporters_dir = ['some/dir']
      user_config = double('config', :reporters_dir => reporters_dir)
      Jasmine::RunnerConfig.new(user_config).reporters_dir.should == reporters_dir
    end
  end

  describe "js_files" do
    it "should return the user js files from the config" do
      js_files = ['some/file']
      user_config = double('config', :js_files => js_files)
      Jasmine::RunnerConfig.new(user_config).js_files.should == js_files
    end
  end

  describe "spec_files" do
    it "should return the user spec_files from the config" do
      spec_files = ['some/file']
      user_config = double('config', :spec_files => spec_files)
      Jasmine::RunnerConfig.new(user_config).spec_files.should == spec_files
    end
  end

  describe "spec_files_full_paths" do
    it "should return the user spec_files_full_paths from the config" do
      spec_files_full_paths = ['some/file_path']
      user_config = double('config', :spec_files_full_paths => spec_files_full_paths)
      Jasmine::RunnerConfig.new(user_config).spec_files_full_paths.should == spec_files_full_paths
    end
  end

  describe "spec_path" do
    it "should return the user spec_path from the config" do
      spec_path = ['some/path']
      user_config = double('config', :spec_path => spec_path)
      Jasmine::RunnerConfig.new(user_config).spec_path.should == spec_path
    end
  end

  describe "spec_dir" do
    it "should return the user spec_dir from the config" do
      spec_dir = ['some/dir']
      user_config = double('config', :spec_dir => spec_dir)
      Jasmine::RunnerConfig.new(user_config).spec_dir.should == spec_dir
    end
  end

  describe "src_dir" do
    it "should return the user src_dir from the config" do
      src_dir = ['some/dir']
      user_config = double('config', :src_dir => src_dir)
      Jasmine::RunnerConfig.new(user_config).src_dir.should == src_dir
    end
  end

  describe "project_root" do
    it "should return the user project_root from the config" do
      project_root = ['some/dir']
      user_config = double('config', :project_root => project_root)
      Jasmine::RunnerConfig.new(user_config).project_root.should == project_root
    end
  end

  describe "root_path" do
    it "should return the user root_path from the config" do
      root_path = ['some/path']
      user_config = double('config', :root_path => root_path)
      Jasmine::RunnerConfig.new(user_config).root_path.should == root_path
    end
  end

  describe "browser" do
    it "should default to firefox" do
      Jasmine::RunnerConfig.new.browser.should == 'firefox'
    end

    it "should use ENV['JASMINE_BROWSER'] if it exists" do
      ENV.stub(:[], "JASMINE_BROWSER").and_return("foo")
      Jasmine::RunnerConfig.new.browser.should == 'foo'
    end
  end


  describe "src_mapper" do
    it "should update the src_mapper in the user_config" do
      config = Jasmine::RunnerConfig.new(user_config = Jasmine::Config.new)
      mapper = double("mapper")
      config.src_mapper = mapper
      config.src_mapper.should == mapper
      user_config.src_mapper.should == mapper
    end
  end

  describe "jasmine_server_url" do
    it "should return the correct server url" do
      host = "the host"
      port =  "484"
      user_config = double('config', :jasmine_host => host, :port => port)
      Jasmine::RunnerConfig.new(user_config).jasmine_server_url.should == "#{host}:#{port}/"
    end
  end

  describe "port" do
    it "should return the port from the config" do
      user_config = double('config', :port => 80)
      Jasmine::RunnerConfig.new(user_config).port.should == 80
    end
  end
  describe "result batch size" do
    subject { Jasmine::RunnerConfig.new.result_batch_size }

    context "when not specified" do
      it("should use default") { should == 50 }
    end

    context "when overridden" do
      before { ENV.stub(:[], "JASMINE_RESULT_BATCH_SIZE").and_return("500") }
      it { should be(500) }
    end
  end
end

