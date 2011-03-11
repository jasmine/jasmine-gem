module Jasmine
  class SeleniumDriver
    def initialize(browser, http_address)
      require 'json/pure' unless defined?(JSON)
      require 'selenium-webdriver'
      @driver = Selenium::WebDriver.for browser.to_sym
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
      JSON.parse("{\"result\":#{result}}")["result"]
    end

    def json_generate(obj)
      JSON.generate(obj)
    end
  end
end