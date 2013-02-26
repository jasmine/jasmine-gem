module Jasmine
  module Formatters
    class Console < Struct.new(:results)
      def summary
        "#{pluralize(results.size, 'spec')}, #{pluralize(results.failures.size, 'failure')}"
      end

      def failures
        results.failures.map { |f| failure_message(f) }.join("\n\n")
      end

      private

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
        template = <<-FE
          #{expectation.message}
          #{expectation.stack_trace}
        FE
      end
    end
  end
end