require 'spec_helper'
require 'selenium-webdriver'

describe Jasmine::Config do
  describe "configuration" do
    before :each do
      Jasmine::Dependencies.stub(:rails_3_asset_pipeline?) { false }

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
          fake_config = Hash.new.stub!(:[]).and_return { |x| ["file1.ext", "file2.ext", "file1.ext"] }
          @config.stub!(:simple_config).and_return(fake_config)
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

      describe "should permit explicity-declared filenames to pass through regardless of their existence" do
        before(:each) do
          Dir.stub!(:glob).and_return { |glob_string| [] }
          fake_config = Hash.new.stub!(:[]).and_return { |x| ["file1.ext", "!file2.ext", "**/*file3.ext"] }
          @config.stub!(:simple_config).and_return(fake_config)
        end

        it "should contain explicitly files" do
          @config.src_files.should == ["file1.ext"]
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


  describe "jasmine_stylesheets" do
    it "should return the relative web server path to the core Jasmine css stylesheets" do
      #TODO: wrap Jasmine::Core with a class that knows about the core path and the relative mapping.
      Jasmine::Core.stub(:css_files).and_return(["my_css_file1.css", "my_css_file2.css"])
      Jasmine::Config.new.jasmine_stylesheets.should == ["/__JASMINE_ROOT__/my_css_file1.css", "/__JASMINE_ROOT__/my_css_file2.css"]
    end
  end

  describe "jasmine_javascripts" do
    it "should return the relative web server path to the core Jasmine css javascripts" do
      Jasmine::Core.stub(:js_files).and_return(["my_js_file1.js", "my_js_file2.js"])
      Jasmine::Config.new.jasmine_javascripts.should == ["/__JASMINE_ROOT__/my_js_file1.js", "/__JASMINE_ROOT__/my_js_file2.js"]
    end
  end

  describe "when the asset pipeline is active" do
    before do
      Jasmine::Dependencies.stub(:rails_3_asset_pipeline?) { true }
    end

    let(:src_files) { ["assets/some.js", "assets/files.js"] }

    let(:config) do
      Jasmine::Config.new.tap do |config|
        #TODO: simple_config should be a passed in hash
        config.stub(:simple_config)  { { 'src_files' => src_files} }
      end
    end

    it "should use AssetPipelineMapper to return src_files" do
      mapped_files =  ["some.js", "files.js"]
      Jasmine::AssetPipelineMapper.stub_chain(:new, :files).and_return(mapped_files)
      config.src_files.should == mapped_files
    end

    it "should pass the config src_files to the AssetPipelineMapper" do
      Jasmine::Config.stub(:simple_config)
      Jasmine::AssetPipelineMapper.should_receive(:new).with(src_files).and_return(double("mapper").as_null_object)
      config.src_files
    end
  end
end
