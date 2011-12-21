module Jasmine
  class SeleniumDriver
    def initialize(browser, http_address)
      require 'selenium-webdriver'
      selenium_server = if ENV['SELENIUM_SERVER']
        ENV['SELENIUM_SERVER']
      elsif ENV['SELENIUM_SERVER_PORT']
        "http://localhost:#{ENV['SELENIUM_SERVER_PORT']}/wd/hub"
      end
      options = if browser == "firefox" && ENV["JASMINE_FIREBUG"]
                  require File.join(File.dirname(__FILE__), "firebug/firebug")
                  profile = Selenium::WebDriver::Firefox::Profile.new
                  profile.enable_firebug
                  {:profile => profile}
                end || {}
      @driver = if selenium_server
        if browser == "htmlunit"
          Selenium::WebDriver.for :remote, :url => selenium_server, :desired_capabilities => Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
        elsif browser == "saucelabs"
          caps = { :platform => ENV['SAUCE_PLATFORM'],
            :browserName => ENV['SAUCE_BROWSER'],
            'browser-version' => ENV['SAUCE_BROWSER_VERSION'],
            'record-screenshots' => ENV['SAUCE_SCREENSHOTS'],
            :name => "Jasmine" }
          Selenium::WebDriver.for :remote, :url => selenium_server, :desired_capabilities => caps
        else
          Selenium::WebDriver.for :remote, :url => selenium_server, :desired_capabilities => browser.to_sym
        end
      else
        Selenium::WebDriver.for browser.to_sym, options
      end
      @http_address = http_address
    end

    def tests_have_finished?
      @driver.execute_script("return window.jasmine.getEnv().currentRunner.finished") == "true"
    end

    def connect
      @driver.navigate.to @http_address
    end

    def disconnect
      @driver.quit
    end

    def run
      until tests_have_finished? do
        sleep 0.1
      end

      puts @driver.execute_script("return window.results()")
      failed_count = @driver.execute_script("return window.jasmine.getEnv().currentRunner.results().failedCount").to_i
      failed_count == 0
    end

    def eval_js(script)
      result = @driver.execute_script(script)
      JSON.parse("{\"result\":#{result}}", :max_nesting => false)["result"]
    end

    def json_generate(obj)
      JSON.generate(obj)
    end
  end
end
