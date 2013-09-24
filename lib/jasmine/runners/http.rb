module Jasmine
  module Runners
    class HTTP
      def initialize(formatter, jasmine_server_url, options)
        @formatter = formatter
        @driver = Jasmine::SeleniumDriver.new(jasmine_server_url, options)
        @reporter = Jasmine::Reporters::ApiReporter.new(driver, options.result_batch_size)
        @results = []
      end

      def run
        driver.connect
        ensure_connection_established
        wait_for_suites_to_finish_running

        @results = reporter.results.map { |r| Result.new(r) }

        formatter.format(results)
        formatter.done

        driver.disconnect
      end

      def succeeded?
        results.detect(&:failed?).nil?
      end

      private

      attr_reader :formatter, :driver, :reporter, :results

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
