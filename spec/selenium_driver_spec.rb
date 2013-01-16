require 'spec_helper'
require 'selenium-webdriver'

describe Jasmine::SeleniumDriver do
  let(:http_client) { mock('http_client', :timeout= => true) }
  let(:webdriver) { mock('webdriver') }
  let(:browser) { "browser" }
  
  describe "initialize" do
    subject { Jasmine::SeleniumDriver }
    context "with a given server" do
      before(:each) do
        ENV.stub!(:[]).with('JASMINE_TIMEOUT').and_return nil
        ENV.stub!(:[]).with('SELENIUM_SERVER').and_return "http://localhost:9999/"
        Selenium::WebDriver.should_receive(:for).with(:remote, :url => "http://localhost:9999/", :desired_capabilities => :browser).and_return webdriver
      end
      it "should initialize the server with the given url" do
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@driver).should == webdriver
      end
      it "should assign the http_address" do
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@http_address).should == "http://localhost:9999/"
      end
    end
    context "with a given port" do
      before(:each) do
        ENV.stub!(:[]).with('JASMINE_TIMEOUT').and_return nil
        ENV.stub!(:[]).with('SELENIUM_SERVER').and_return nil
        ENV.stub!(:[]).with('SELENIUM_SERVER_PORT').and_return "9999"
        Selenium::WebDriver.should_receive(:for).with(:remote, :url => "http://localhost:9999/wd/hub", :desired_capabilities => :browser).and_return webdriver
      end
      it "should initialize the server with the given url" do
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@driver).should == webdriver
      end
      it "should assign the http_address" do
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@http_address).should == "http://localhost:9999/"
      end
    end
    context "with no given server or port" do
      before(:each) do
        ENV.stub! :[] => nil
        Selenium::WebDriver.should_receive(:for).with(:browser, {}).and_return webdriver
      end
      it "should initialize the server with the given url" do
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@driver).should == webdriver
      end
      it "should assign the http_address" do
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@http_address).should == "http://localhost:9999/"
      end
    end
    context "with a given timeout" do
      before(:each) do
        ENV.stub!(:[]).with('SELENIUM_SERVER').and_return nil
        ENV.stub!(:[]).with('SELENIUM_SERVER_PORT').and_return nil
        ENV.stub!(:[]).with('JASMINE_FIREBUG').and_return nil
        ENV.stub!(:[]).with('JASMINE_TIMEOUT').and_return "500"
      end
      it "should initialize the server with the given timeout" do
        Selenium::WebDriver::Remote::Http::Default.should_receive(:new).and_return(http_client)
        http_client.should_receive(:timeout=).with(500)
        Selenium::WebDriver.should_receive(:for).with(:browser, {:http_client => http_client}).and_return webdriver
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@driver).should == webdriver
      end
    end
    context "with firebug" do
      let(:browser) { "firefox" }
      let(:profile) { mock('firefox_profile') }
      before(:each) do
        ENV.stub!(:[]).with('SELENIUM_SERVER').and_return nil
        ENV.stub!(:[]).with('SELENIUM_SERVER_PORT').and_return nil
        ENV.stub!(:[]).with('JASMINE_FIREBUG').and_return "true"
        ENV.stub!(:[]).with('JASMINE_TIMEOUT').and_return nil
      end
      it "should initialize firefox with firebug" do
        Selenium::WebDriver::Firefox::Profile.should_receive(:new).and_return profile
        profile.should_receive(:enable_firebug)
        Selenium::WebDriver.should_receive(:for).with(:firefox, {:profile => profile}).and_return webdriver
        subject.new(browser, "http://localhost:9999/").instance_variable_get(:@driver).should == webdriver
      end
    end
  end
  
  describe "instance methods" do
    subject { Jasmine::SeleniumDriver.new("browser", 'http://fake.url') }
    before(:each) do
      ENV.stub! :[] => nil
      Selenium::WebDriver.stub! :for => webdriver
      Selenium::WebDriver::Remote::Http::Default.stub! :new => http_client
      subject.instance_variable_set(:@driver, webdriver)
    end
    describe "connect" do
      let(:navigator) { mock('navigator') }
      it "should tell the driver to navigate to the given url" do
        webdriver.should_receive(:navigate).and_return navigator
        navigator.should_receive(:to).with('http://fake.url')
        subject.connect
      end
    end
    describe "disconnect" do
      it "should tell the driver to quit" do
        webdriver.should_receive(:quit)
        subject.disconnect
      end
    end
    describe "eval_js" do
      it "should execute the given script and return a result" do
        webdriver.should_receive(:execute_script).with('SCRIPT').and_return('json')
        JSON.should_receive(:parse).with("{\"result\":json}", :max_nesting => false).and_return "result" => 'RESULT'
        subject.eval_js('SCRIPT').should == 'RESULT'
      end
    end
    describe "json_generate" do
      it "should delegate to json" do
        JSON.should_receive(:generate).with('something').and_return 'json'
        subject.json_generate('something').should == 'json'
      end
    end
  end

  
end
