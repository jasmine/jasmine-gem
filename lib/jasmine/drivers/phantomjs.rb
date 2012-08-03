module Jasmine
  module Drivers
    class Phantomjs
      def initialize(http_address, runner_config)
        require "phantomjs_driver"
        @http_address = http_address
        @driver = ::PhantomjsDriver::Driver.new
      end

      def connect
        @driver.visit @http_address
      end

      def disconnect
        @driver.quit
      end

      def eval_js(script)
        script = "(function(){#{script}})()"
        result = @driver.evaluate_script(script)
        JSON.parse("{\"result\":#{result}}", :max_nesting => false)["result"]
      end

      def json_generate(obj)
        JSON.generate(obj)
      end
    end
  end
end

