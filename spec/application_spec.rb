require 'spec_helper'
require 'rack/test'

describe "Jasmine::Application" do
  include Rack::Test::Methods

  def app
    @root = File.join(File.dirname(__FILE__))
    runner_config = double("config",
                    :project_root => @root,
                    :spec_dir => File.join(@root, "fixture", "spec"),
                    :spec_path => "/__spec__",
                    :root_path => "/__root__",
                    :css_files => [],
                    :jasmine_files => [],
                    :js_files => ["path/file1.js", "path/file2.js"],
                    :src_dir => File.join(@root, "fixture", "src"),
                    :src_files => ["file1.js"],
                    :spec_files => ["example_spec.js"])
    Jasmine::Application.app(runner_config)
  end

  it "includes no-cache headers for specs" do
    get "/__spec__/example_spec.js"
    last_response.headers.should have_key("Cache-Control")
    last_response.headers["Cache-Control"].should == "max-age=0, private, must-revalidate"
  end

  it "should serve static files from spec dir under __spec__" do
    get "/__spec__/example_spec.js"
    last_response.status.should == 200
    last_response.content_type.should == "application/javascript"
    last_response.body.should == File.read(File.join(@root, "fixture/spec/example_spec.js"))
    end

  it "should serve static files from root dir under __root__" do
    get "/__root__/fixture/src/example.js"
    last_response.status.should == 200
    last_response.content_type.should == "application/javascript"
    last_response.body.should == File.read(File.join(@root, "fixture/src/example.js"))
  end

  it "should serve static files from src dir under /" do
    get "/example.js"
    last_response.status.should == 200
    last_response.content_type.should == "application/javascript"
    last_response.body.should == File.read(File.join(@root, "fixture/src/example.js"))
  end

  it "should serve Jasmine static files under /__JASMINE_ROOT__/" do
    get "/__JASMINE_ROOT__/jasmine.css"
    last_response.status.should == 200
    last_response.content_type.should == "text/css"
    last_response.body.should == File.read(File.join(Jasmine::Core.path, "jasmine.css"))
  end

  it "should serve focused suites when prefixing spec files with /__suite__/" do
    pending "Temporarily removing this feature (maybe permanent)"
    Dir.stub!(:glob).and_return { |glob_string| [glob_string] }
    get "/__suite__/file2.js"
    last_response.status.should == 200
    last_response.content_type.should == "text/html"
    last_response.body.should include("\"/__spec__/file2.js")
  end

  it "should redirect /run.html to /" do
    get "/run.html"
    last_response.status.should == 302
    last_response.location.should == "/"
  end

  it "should 404 non-existent files" do
    get "/some-non-existent-file"
    last_response.should be_not_found
  end

  describe "/ page" do
    it "should load each js file in order" do
      get "/"
      last_response.status.should == 200
      last_response.body.should include("path/file1.js")
      last_response.body.should include("path/file2.js")
    end

    it "should return an empty 200 for HEAD requests to /" do
      head "/"
      last_response.status.should == 200
      last_response.headers['Content-Type'].should == 'text/html'
      last_response.body.should == ''
    end

    it "should tell the browser not to cache any assets" do
      head "/"
      ['Pragma'].each do |key|
        last_response.headers[key].should == 'no-cache'
      end
    end
  end
end
