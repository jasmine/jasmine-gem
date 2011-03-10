require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

describe Jasmine::Config do
  describe "configuration" do
    before :each do
      temp_dir_before

      Dir::chdir @tmp
      dir_name = "test_js_project"
      `mkdir -p #{dir_name}`
      Dir::chdir dir_name
      `#{@root}/bin/jasmine init .`

      @project_dir  = Dir.pwd

      @template_dir = File.expand_path(File.join(@root, "generators/jasmine/templates"))
      @config       = Jasmine::Config.new
    end

    after(:each) do
      temp_dir_after
    end

    describe "defaults" do
      it "src_dir uses root when src dir is blank" do
        @config.stub!(:project_root).and_return('some_project_root')
        @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
        YAML.stub!(:load).and_return({'src_dir' => nil})
        @config.src_dir.should == 'some_project_root'
      end

      it "should use correct default yaml config" do
        @config.stub!(:project_root).and_return('some_project_root')
        @config.simple_config_file.should == (File.join('some_project_root', 'spec/javascripts/support/jasmine.yml'))
      end
    end

    describe "simple_config" do
      before(:each) do
        @config.stub!(:src_dir).and_return(File.join(@project_dir, "."))
        @config.stub!(:spec_dir).and_return(File.join(@project_dir, "spec/javascripts"))
      end

      describe "using default jasmine.yml" do
        before(:each) do
          @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
        end

        it "should find the source files" do
          @config.src_files.should =~ ['public/javascripts/Player.js', 'public/javascripts/Song.js']
        end

        it "should find the stylesheet files" do
          @config.stylesheets.should == []
        end

        it "should find the spec files" do
          @config.spec_files.should == ['PlayerSpec.js']
        end

        it "should find any helpers" do
          @config.helpers.should == ['helpers/SpecHelper.js']
        end
        
        it "should find external sources empty" do
          @config.external_files.should == []
        end

        it "should build an array of all the JavaScript files to include, source files then spec files" do
          @config.js_files.should == [
                  '/public/javascripts/Player.js',
                  '/public/javascripts/Song.js',
                  '/__spec__/helpers/SpecHelper.js',
                  '/__spec__/PlayerSpec.js'
          ]
        end

        it "should allow the js_files to be filtered" do
          @config.js_files("PlayerSpec.js").should == [
                  '/public/javascripts/Player.js',
                  '/public/javascripts/Song.js',
                  '/__spec__/helpers/SpecHelper.js',
                  '/__spec__/PlayerSpec.js'
          ]
        end

        it "should report the full paths of the spec files" do
          @config.spec_files_full_paths.should == [File.join(@project_dir, 'spec/javascripts/PlayerSpec.js')]
        end
      end

      it "should parse ERB" do
        @config.stub!(:simple_config_file).and_return(File.expand_path(File.join(@root, 'spec', 'fixture','jasmine.erb.yml')))
        Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
        @config.src_files.should == ['file0.js', 'file1.js', 'file2.js',]
      end
      
      it "should put external files before others" do
        @config.stub!(:simple_config_file).and_return(File.expand_path(File.join(@root, 'spec', 'fixture','jasmine.externals.yml')))
        Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
        @config.js_files[0].should == 'http://some.external.file.js'
      end

      describe "if jasmine.yml not found" do
        before(:each) do
          File.stub!(:exist?).and_return(false)
        end

        it "should default to loading no source files" do
          @config.src_files.should be_empty
        end

        it "should default to loading no stylesheet files" do
          @config.stylesheets.should be_empty
        end

      end

      describe "if jasmine.yml is empty" do
        before(:each) do
          @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))
          YAML.stub!(:load).and_return(false)
        end

        it "should default to loading no source files" do
          @config.src_files.should be_empty
        end

        it "should default to loading no stylesheet files" do
          @config.stylesheets.should be_empty
        end
      end

      describe "should use the first appearance of duplicate filenames" do
        before(:each) do
          Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
          @config.stub!(:simple_config).and_return({
            'src_files' => ["file1.ext", "file2.ext", "file1.ext"],
            'stylesheets' => ["file1.ext", "file2.ext", "file1.ext"],
            'spec_files' => ["file1.ext", "file2.ext", "file1.ext"],
            'helpers' => ["file1.ext", "file2.ext", "file1.ext"],
          })
        end

        it "src_files" do
          @config.src_files.should == ['file1.ext', 'file2.ext']
        end

        it "stylesheets" do
          @config.stylesheets.should == ['file1.ext', 'file2.ext']
        end

        it "spec_files" do
          @config.spec_files.should == ['file1.ext', 'file2.ext']
        end

        it "helpers" do
          @config.spec_files.should == ['file1.ext', 'file2.ext']
        end

        it "js_files" do
          @config.js_files.should == ["/file1.ext",
                                      "/file2.ext",
                                      "/__spec__/file1.ext",
                                      "/__spec__/file2.ext",
                                      "/__spec__/file1.ext",
                                      "/__spec__/file2.ext"]
        end

        it "spec_files_full_paths" do
          @config.spec_files_full_paths.should == [
                  File.expand_path("spec/javascripts/file1.ext", @project_dir),
                  File.expand_path("spec/javascripts/file2.ext", @project_dir)
          ]
        end
      end

      describe "should allow .gitignore style negation (!pattern)" do
        before(:each) do
          Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
          fake_config = Hash.new.stub!(:[]).and_return { |x| ["file1.ext", "!file1.ext", "file2.ext"] }
          @config.stub!(:simple_config).and_return(fake_config)
        end

        it "should not contain negated files" do
          @config.src_files.should == ["file2.ext"]
        end
      end

      it "simple_config stylesheets" do
        @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine.yml'))

        YAML.stub!(:load).and_return({'stylesheets' => ['foo.css', 'bar.css']})
        Dir.stub!(:glob).and_return { |glob_string| [glob_string] }

        @config.stylesheets.should == ['foo.css', 'bar.css']
      end

      it "using rails jasmine.yml" do
        ['public/javascripts/prototype.js',
         'public/javascripts/effects.js',
         'public/javascripts/controls.js',
         'public/javascripts/dragdrop.js',
         'public/javascripts/application.js'].each { |f| `touch #{f}` }

        @config.stub!(:simple_config_file).and_return(File.join(@template_dir, 'spec/javascripts/support/jasmine-rails.yml'))

        @config.spec_files.should == ['PlayerSpec.js']
        @config.helpers.should == ['helpers/SpecHelper.js']
        @config.src_files.should == ['public/javascripts/prototype.js',
                                     'public/javascripts/effects.js',
                                     'public/javascripts/controls.js',
                                     'public/javascripts/dragdrop.js',
                                     'public/javascripts/application.js',
                                     'public/javascripts/Player.js',
                                     'public/javascripts/Song.js']
        @config.js_files.should == [
                '/public/javascripts/prototype.js',
                '/public/javascripts/effects.js',
                '/public/javascripts/controls.js',
                '/public/javascripts/dragdrop.js',
                '/public/javascripts/application.js',
                '/public/javascripts/Player.js',
                '/public/javascripts/Song.js',
                '/__spec__/helpers/SpecHelper.js',
                '/__spec__/PlayerSpec.js',
        ]
        @config.js_files("PlayerSpec.js").should == [
                '/public/javascripts/prototype.js',
                '/public/javascripts/effects.js',
                '/public/javascripts/controls.js',
                '/public/javascripts/dragdrop.js',
                '/public/javascripts/application.js',
                '/public/javascripts/Player.js',
                '/public/javascripts/Song.js',
                '/__spec__/helpers/SpecHelper.js',
                '/__spec__/PlayerSpec.js'
        ]
      end
    end
  end

  describe "browser configuration" do
    it "should use firefox by default" do
      ENV.stub!(:[], "JASMINE_BROWSER").and_return(nil)
      config = Jasmine::Config.new
      config.stub!(:start_servers)
      Jasmine::SeleniumDriver.should_receive(:new).
              with(anything(), anything(), "*firefox", anything()).
              and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end

    it "should use ENV['JASMINE_BROWSER'] if set" do
      ENV.stub!(:[], "JASMINE_BROWSER").and_return("mosaic")
      config = Jasmine::Config.new
      config.stub!(:start_servers)
      Jasmine::SeleniumDriver.should_receive(:new).
              with(anything(), anything(), "*mosaic", anything()).
              and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end
  end

  describe "jasmine host" do
    it "should use http://localhost by default" do
      config = Jasmine::Config.new
      config.instance_variable_set(:@jasmine_server_port, '1234')
      config.stub!(:start_servers)

      Jasmine::SeleniumDriver.should_receive(:new).
              with(anything(), anything(), anything(), "http://localhost:1234/").
              and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end

    it "should use ENV['JASMINE_HOST'] if set" do
      ENV.stub!(:[], "JASMINE_HOST").and_return("http://some_host")
      config = Jasmine::Config.new
      config.instance_variable_set(:@jasmine_server_port, '1234')
      config.stub!(:start_servers)

      Jasmine::SeleniumDriver.should_receive(:new).
              with(anything(), anything(), anything(), "http://some_host:1234/").
              and_return(mock(Jasmine::SeleniumDriver, :connect => true))
      config.start
    end
  end

  describe "#start_selenium_server" do
    it "should use an existing selenium server if SELENIUM_SERVER_PORT is set" do
      config = Jasmine::Config.new
      ENV.stub!(:[], "SELENIUM_SERVER_PORT").and_return(1234)
      Jasmine.should_receive(:wait_for_listener).with(1234, "selenium server")
      config.start_selenium_server
    end
  end
end
