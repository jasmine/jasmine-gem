require File.join(File.dirname(__FILE__), "phantomjs/browser")
require File.join(File.dirname(__FILE__), "phantomjs/errors")
module Jasmine
  module Drivers
    class Phantomjs
      attr_accessor :browser, :http_address

      def initialize(http_address, runner_config)
        @http_address = http_address
        @browser = Browser.new(:phantomjs_path => runner_config.phantomjs_path)
      end

      def connect
        browser.visit http_address
      end

      def disconnect
        browser.server.stop
        browser.client.stop
      end

      def eval_js(script)
        script = "(function(){#{script}})()"
        result = browser.evaluate(script)
        JSON.parse("{\"result\":#{result}}", :max_nesting => false)["result"]
      end

      def json_generate(obj)
        JSON.generate(obj)
      end
    end
  end
end

