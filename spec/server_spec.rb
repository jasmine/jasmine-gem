require File.expand_path(File.join(File.dirname(__FILE__), "spec_helper"))

def read(body)
  return body if body.is_a?(String)
  out = ""
  body.each {|data| out += data }
  out
end

describe Jasmine::Server do
  before(:each) do
    config = Jasmine::Config.new
    config.stub!(:spec_dir).and_return(File.join(Jasmine.root, "spec"))
    config.stub!(:src_dir).and_return(File.join(Jasmine.root, "src"))
    config.stub!(:src_files).and_return(["file1.js"])
    config.stub!(:spec_files).and_return(["file2.js"])

    @server = Jasmine::Server.new(0, config)
    @thin_app = @server.thin.app
  end

  after(:each) do
    @server.thin.stop if @server && @server.thin.running?
  end

  it "should serve static files from spec dir under __spec__" do
    code, headers, body = @thin_app.call("PATH_INFO" => "/__spec__/suites/EnvSpec.js", "SCRIPT_NAME" => "xxx")
    code.should == 200
    headers["Content-Type"].should == "application/javascript"
    read(body).should == File.read(File.join(Jasmine.root, "spec/suites/EnvSpec.js"))
    end

  it "should serve static files from root dir under /" do
    code, headers, body = @thin_app.call("PATH_INFO" => "/base.js", "SCRIPT_NAME" => "xxx")
    code.should == 200
    headers["Content-Type"].should == "application/javascript"
    read(body).should == File.read(File.join(Jasmine.root, "src/base.js"))
  end

  it "should serve Jasmine static files under /__JASMINE_ROOT__/" do
    code, headers, body = @thin_app.call("PATH_INFO" => "/__JASMINE_ROOT__/lib/jasmine.css", "SCRIPT_NAME" => "xxx")
    code.should == 200
    headers["Content-Type"].should == "text/css"
    read(body).should == File.read(File.join(Jasmine.root, "lib/jasmine.css"))
  end

  it "should serve focused suites when prefixing spec files with /__suite__/" do
    Dir.stub!(:glob).and_return do |glob_string|
      glob_string
    end
    code, headers, body = @thin_app.call("PATH_INFO" => "/__suite__/file2.js", "SCRIPT_NAME" => "xxx")
    code.should == 200
    headers["Content-Type"].should == "text/html"
    read(body).should include("\"/__spec__/file2.js")
  end

  it "should redirect /run.html to /" do
    code, headers, body = @thin_app.call("PATH_INFO" => "/run.html", "SCRIPT_NAME" => "xxx")
    code.should == 302
    headers["Location"].should == "/"
  end

  it "should 404 non-existent files" do
    code, headers, body = @thin_app.call("PATH_INFO" => "/some-non-existent-file", "SCRIPT_NAME" => "xxx")
    code.should == 404

  end

  describe "/ page" do
    it "should load each js file in order" do
      code, headers, body = @thin_app.call("PATH_INFO" => "/", "SCRIPT_NAME" => "xxx", "REQUEST_METHOD" => 'GET')
      code.should == 200
      body = read(body)
      body.should include("\"/file1.js")
      body.should include("\"/__spec__/file2.js")
      body.should satisfy {|s| s.index("/file1.js") < s.index("/__spec__/file2.js") }
    end

    it "should return an empty 200 for HEAD requests to /" do
      code, headers, body = @thin_app.call("PATH_INFO" => "/", "SCRIPT_NAME" => "xxx", "REQUEST_METHOD" => 'HEAD')
      code.should == 200
      headers.should == { 'Content-Type' => 'text/html' }
      body.should == ''
    end

  end

end