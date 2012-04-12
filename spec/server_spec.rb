require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))
require 'rack/test'

describe "Jasmine.app" do
  include Rack::Test::Methods

  def app
    config = Jasmine::Config.new
    @root = File.join(File.dirname(__FILE__))
    my_rack_apps = {
      "/my_rack1" => proc { [200, { "Content-Type" => "text/plain" }, ["Rack me once, shame on you"]] },
      "/my_rack2" => proc { [200, { "Content-Type" => "text/plain" }, ["Rack me twice, shame on me"]] }
    }

    config.stub!(:project_root).and_return(@root)
    config.stub!(:spec_dir).and_return(File.join(@root, "fixture", "spec"))
    config.stub!(:src_dir).and_return(File.join(@root, "fixture", "src"))
    config.stub!(:src_files).and_return(["file1.js"])
    config.stub!(:spec_files).and_return(["file2.js"])
    config.stub!(:mount_apps).and_return(my_rack_apps)
    Jasmine.app(config)
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

  describe "user rack apps" do
    it "should mount and user provided rack apps" do
      get "/my_rack1"
      last_response.status.should == 200
      last_response.content_type.should == "text/plain"
      last_response.body.should == "Rack me once, shame on you"

      get "/my_rack2"
      last_response.status.should == 200
      last_response.content_type.should == "text/plain"
      last_response.body.should == "Rack me twice, shame on me"
    end
  end

  describe "/ page" do
    it "should load each js file in order" do
      get "/"
      last_response.status.should == 200
      last_response.body.should include("\"/file1.js")
      last_response.body.should include("\"/__spec__/file2.js")
      last_response.body.should satisfy {|s| s.index("/file1.js") < s.index("/__spec__/file2.js") }
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
