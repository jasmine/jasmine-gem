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
        timeout = ENV['SELENIUM_CLIENT_TIMEOUT'] == nil ? 120 : ENV['SELENIUM_CLIENT_TIMEOUT']
        if browser == "htmlunit"
          client = Selenium::WebDriver::Remote::Http::Default.new
          client.timeout = timeout
          options[:http_client] = client
          options[:url] = selenium_server
          options[:desired_capabilities] = Selenium::WebDriver::Remote::Capabilities.htmlunit(:javascript_enabled => true)
          Selenium::WebDriver.for :remote, options
        elsif browser == "saucelabs"
          caps = { :platform => ENV['SAUCE_PLATFORM'] == nil ? :VISTA : ENV['SAUCE_PLATFORM'].to_s.upcase.to_sym,
            :browserName => ENV['SAUCE_BROWSER'],
            'browser-version' => ENV['SAUCE_BROWSER_VERSION'],
            'record-screenshots' => ENV['SAUCE_SCREENSHOTS'] == nil ? false : ENV['SAUCE_SCREENSHOTS'],
            'record-video' => ENV['SAUCE_VIDEO'] == nil ? false : ENV['SAUCE_VIDEO'],
            'idle-timeout' => ENV['SAUCE_IDLE_TIMEOUT'] == nil ? 120 : ENV['SAUCE_IDLE_TIMEOUT'],
            'max-duration' => ENV['SAUCE_MAX_DURATION'] == nil ? 120 : ENV['SAUCE_MAX_DURATION'],
            :name => "Jasmine" }

          client = Selenium::WebDriver::Remote::Http::Default.new
          client.timeout = timeout
          options[:http_client] = client
          options[:url] = selenium_server
          options[:desired_capabilities] = caps

          Selenium::WebDriver.for :remote, options
        else
          Selenium::WebDriver.for :remote, :url => selenium_server, :desired_capabilities => browser.to_sym
        end
      else
        Selenium::WebDriver.for browser.to_sym, options
      end
      @http_address = http_address
    end

    def tests_have_finished?
      @driver.execute_script('return jsApiReporter.finished')
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

      puts @driver.execute_script("return jsApiReporter.results()")
      failed_count = @driver.execute_script("return window.jasmine.getEnv().currentRunner.results().failedCount").to_i
      failed_count == 0
    end

    def eval_js(script)
      1.upto(3) do
        begin
          result = @driver.execute_script(script)
          return JSON.parse("{\"result\":#{result}}", :max_nesting => false)["result"]
        rescue Exception => e
          puts "Caught exception in eval_js #{e.message}\n#{e.backtrace}"
          sleep 1
        end
      end
    end

    def json_generate(obj)
      JSON.generate(obj)
    end
  end
end
