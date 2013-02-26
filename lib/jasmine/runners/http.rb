module Jasmine
  module Runners
    class HTTP < Struct.new(:driver, :reporter)
      def run
        driver.connect
        ensure_connection_established
        wait_for_suites_to_finish_running

        results = reporter.results

        driver.disconnect
        results
      end

      private
      
      def ensure_connection_established
        started = Time.now
        until reporter.started? do
          raise "couldn't connect to Jasmine after 60 seconds" if (started + 60 < Time.now)
          sleep 0.1
        end
      end

      def wait_for_suites_to_finish_running
        puts "Waiting for suite to finish in browser ..."
        until reporter.finished? do
          sleep 0.1
        end
      end
    end
  end
end
