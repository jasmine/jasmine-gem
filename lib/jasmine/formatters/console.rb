module Jasmine
  module Formatters
    class Console
      def initialize(outputter = Kernel)
        @results = []
        @outputter = outputter
      end

      def format(results_batch)
        outputter.print(chars(results_batch))
        @results += results_batch
      end

      def done
        outputter.puts
        outputter.puts(failures(@results))
        failure_count = results.count(&:failed?)
        pending_count = results.count(&:pending?)
        summary = "#{pluralize(results.size, 'spec')}, " +
          "#{pluralize(failure_count, 'failure')}"

        summary += ", #{pluralize(pending_count, 'pending spec')}" if pending_count > 0

        outputter.puts(summary)
      end

      private
      attr_reader :results, :outputter

      def failures(results)
        results.select(&:failed?).map { |f| failure_message(f) }.join("\n\n")
      end

      def chars(results)
        results.map do |result|
          if result.succeeded?
            '.'
          elsif result.pending?
            '*'
          else
            'F'
          end
        end.join('')
      end

      def pluralize(count, str)
        word = (count == 1) ? str : str + 's'
        "#{count} #{word}"
      end

      def failure_message(failure)
        template = <<-FM
          #{failure.full_name}\n
        FM

        template += failure.failed_expectations.map { |fe| expectation_message(fe) }.join("\n")
      end

      def expectation_message(expectation)
        <<-FE
          #{expectation.message}
          #{expectation.stack}
        FE
      end
    end
  end
end
