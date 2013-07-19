begin
  require 'json'
rescue LoadError
  puts "You must have a JSON library installed to run jasmine:ci. Try \"gem install json\""
end

module Jasmine
  class SeleniumDriver
    def initialize(browser, http_address)
      require 'selenium-webdriver'

      selenium_server = if Jasmine.config.selenium_server
                          Jasmine.config.selenium_server
                        elsif Jasmine.config.selenium_server_port
                          "http://localhost:#{Jasmine.config.selenium_server_port}/wd/hub"
                        end
      options = if browser == 'firefox-firebug'
                  require File.join(File.dirname(__FILE__), 'firebug/firebug')
                  (profile = Selenium::WebDriver::Firefox::Profile.new)
                  profile.enable_firebug
                  {:profile => profile}
                end || {}
      
      if ENV['JASMINE_TIMEOUT']
        http_client = Selenium::WebDriver::Remote::Http::Default.new
        http_client.timeout = ENV['JASMINE_TIMEOUT'].to_i
        options.merge! :http_client => http_client
      end
      
      @driver = if selenium_server
        Selenium::WebDriver.for :remote, :url => selenium_server, :desired_capabilities => browser.to_sym
      else
        Selenium::WebDriver.for browser.to_sym, options
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
      result = @driver.execute_script(script)
      JSON.parse("{\"result\":#{result.to_json}}", :max_nesting => false)['result']
    end

    def json_generate(obj)
      JSON.generate(obj)
    end
  end
end
