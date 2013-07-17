module Jasmine
  module Reporters
    #TODO: where does this live?
    class ApiReporter < Struct.new(:driver, :batch_size)
      STARTED_JS = "return jsApiReporter && jsApiReporter.started"
      FINISHED_JS = "return jsApiReporter && jsApiReporter.finished"

      def started?
        driver.eval_js STARTED_JS
      end

      def finished?
        driver.eval_js FINISHED_JS
      end

      def results
        index = 0
        spec_results = []

        loop do
          slice = get_results_slice(index)
          spec_results << slice
          index += batch_size

          break if slice.size < batch_size
        end

        spec_results.flatten
      end

      private

      def get_results_slice(index)
        driver.eval_js("return jsApiReporter.specResults(#{index}, #{batch_size})")
      end
    end
  end
end