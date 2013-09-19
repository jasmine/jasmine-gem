module Jasmine
  module Formatters
    class Console < BaseFormatter
      def format(results)
        puts failures(results)
        puts summary(results)
      end

      def summary(results)
        summary = "#{pluralize(results.size, 'spec')}, " +
          "#{pluralize(results.failures.size, 'failure')}"

        summary += ", #{pluralize(results.pending_specs.size, 'pending spec')}" unless results.pending_specs.empty?

        summary
      end

      def failures(results)
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
        <<-FE
          #{expectation.message}
          #{expectation.stack}
        FE
      end
    end
  end
end
