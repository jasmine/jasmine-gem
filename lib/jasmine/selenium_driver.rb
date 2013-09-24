module Jasmine
  require 'json'
  class SeleniumDriver
    def initialize(http_address, options)
      require 'selenium-webdriver'
      browser = options.browser

      selenium_server = if options.selenium_server
                          options.selenium_server
                        elsif options.selenium_server_port
                          "http://localhost:#{options.selenium_server_port}/wd/hub"
                        end

      selenium_options = {}
      if browser == 'firefox-firebug'
        require File.join(File.dirname(__FILE__), 'firebug/firebug')
        (profile = Selenium::WebDriver::Firefox::Profile.new)
        profile.enable_firebug
        selenium_options[:profile] = profile
      end

      @driver = if options.webdriver
                  options.webdriver
                elsif selenium_server
                  Selenium::WebDriver.for :remote, :url => selenium_server, :desired_capabilities => browser.to_sym
                else
                  Selenium::WebDriver.for browser.to_sym, selenium_options
                end
      @http_address = http_address
    end

    def connect
      @driver.navigate.to @http_address
    end

    def disconnect
      @driver.quit
    end

    def eval_js(script)
      @driver.execute_script(script)
    end

  end
end
