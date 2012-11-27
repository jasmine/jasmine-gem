require 'spec_helper'

describe Jasmine::YamlConfigParser do
  # before :each do
  # Jasmine::Dependencies.stub(:rails_3_asset_pipeline?) { false }

  # temp_dir_before

  # Dir::chdir @tmp
  # dir_name = "test_js_project"
  # `mkdir -p #{dir_name}`
  # Dir::chdir dir_name
  # `#{@root}/bin/jasmine init .`

  # @project_dir  = Dir.pwd

  # @template_dir = File.expand_path(File.join(@root, "generators/jasmine/templates"))
  # @config       = Jasmine::Config.new
  # end

  # after(:each) do
  # temp_dir_after
  # end

  it "src_dir uses current working directory when src dir is blank" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"src_dir" => nil}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    parser.src_dir.should == 'some_project_root'
  end

  it "src_dir returns src_dir if set" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"src_dir" => 'some_src_dir'}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    parser.src_dir.should == File.join('some_project_root', 'some_src_dir')
  end

  it "spec_dir uses default path when spec dir is blank" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"spec_dir" => nil}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    parser.spec_dir.should == File.join('some_project_root', 'spec', 'javascripts')
  end

  it "spec_dir returns spec_dir if set" do
    yaml_loader = lambda do |path|
      if path == "some_path"
        {"spec_dir" => "some_spec_dir"}
      end
    end
    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', nil, yaml_loader)
    parser.spec_dir.should == File.join('some_project_root', 'some_spec_dir')
  end

  it "expands src_file paths" do
    expander = lambda do |dir, patterns|
      if (dir == File.join('some_project_root', 'some_src') && patterns == ['some_patterns'])
        ['expected_results']
      end
    end
    yaml_loader = lambda do |path|
      if path == "some_path"
        { 'src_dir' => 'some_src', 'src_files' => ['some_patterns'] }
      end
    end

    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', expander, yaml_loader)

    parser.src_files.should == ['expected_results']
  end

  it "expands stylesheets paths" do
    expander = lambda do |dir, patterns|
      if (dir == File.join('some_project_root', 'some_src') && patterns == ['some_patterns'])
        ['expected_results']
      end
    end
    yaml_loader = lambda do |path|
      if path == "some_path"
        { 'src_dir' => 'some_src', 'stylesheets' => ['some_patterns'] }
      end
    end

    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', expander, yaml_loader)

    parser.css_files.should == ['expected_results']
  end

  it "expands spec_file paths" do
    expander = lambda do |dir, patterns|
      if (dir == File.join('some_project_root', 'some_spec') && patterns == ['some_patterns'])
        ['expected_results']
      end
    end
    yaml_loader = lambda do |path|
      if path == "some_path"
        { 'spec_dir' => 'some_spec', 'spec_files' => ['some_patterns'] }
      end
    end

    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', expander, yaml_loader)

    parser.spec_files.should == ['expected_results']
  end

  it "expands helper paths" do
    expander = lambda do |dir, patterns|
      if (dir == File.join('some_project_root', 'some_spec') && patterns == ['some_patterns'])
        ['expected_results']
      end
    end
    yaml_loader = lambda do |path|
      if path == "some_path"
        { 'spec_dir' => 'some_spec', 'helpers' => ['some_patterns'] }
      end
    end

    parser = Jasmine::YamlConfigParser.new('some_path', 'some_project_root', expander, yaml_loader)

    parser.helpers.should == ['expected_results']
  end

  it "doesn't blow up when blank values are passed" do
    expander = lambda do |dir, patterns|
      raise 'bad arguments' unless patterns.is_a?(Array)
      []
    end
    yaml_loader = lambda do |path|
      {}
    end

    parser = Jasmine::YamlConfigParser.new({}, 'some_project_root', expander, yaml_loader)
    parser.src_files.should == []
    parser.spec_files.should == []
    parser.css_files.should == []
    parser.helpers.should == []
  end


  # it "should parse ERB" do
  # @config.stub!(:simple_config_file).and_return(File.expand_path(File.join(@root, 'spec', 'fixture','jasmine.erb.yml')))
  # Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
  # @config.src_files.should == ['file0.js', 'file1.js', 'file2.js',]
  # end

end
