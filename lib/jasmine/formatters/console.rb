module Jasmine
  module Formatters
    class Console
      def initialize(config, outputter = Kernel)
        @config = config
        @results = []
        @outputter = outputter
      end

      def format(results_batch)
        outputter.print(chars(results_batch))
        @results += results_batch
      end

      def done(run_details)
        outputter.puts

        run_result = global_failure_details(run_details)

        failure_count = results.count(&:failed?)
        if failure_count > 0
          outputter.puts('Failures:')
          outputter.puts(failures(@results))
          outputter.puts
        end

        pending_count = results.count(&:pending?)
        if pending_count > 0
          outputter.puts('Pending:')
          outputter.puts(pending(@results))
          outputter.puts
        end

        deprecationWarnings = (@results + [run_result]).map(&:deprecation_warnings).flatten
        if deprecationWarnings.size > 0
          outputter.puts('Deprecations:')
          outputter.puts(deprecations(deprecationWarnings))
          outputter.puts
        end

        summary = "#{pluralize(results.size, 'spec')}, " +
          "#{pluralize(failure_count, 'failure')}"

        summary += ", #{pluralize(pending_count, 'pending spec')}" if pending_count > 0

        outputter.puts(summary)

        if run_details['overallStatus'] == 'incomplete'
          outputter.puts("Incomplete: #{run_details['incompleteReason']}")
        end

        if run_details['order'] && run_details['order']['random']
          seed = run_details['order']['seed']
          outputter.puts("Randomized with seed #{seed} \(rake jasmine:ci\[true,#{seed}])")
        end
      end

      private
      attr_reader :results, :outputter

      def failures(results)
        results.select(&:failed?).map { |f| failure_message(f) }.join("\n\n")
      end

      def pending(results)
        results.select(&:pending?).map { |spec| pending_message(spec) }.join("\n\n")
      end

      def deprecations(warnings)
        warnings.map { |w| expectation_message(w) }.join("\n\n")
      end

      def global_failure_details(run_details)
        result = Jasmine::Result.new(run_details.merge('fullName' => 'Error occurred in afterAll', 'description' => ''))
        if (result.failed_expectations.size > 0)
          (loadFails, afterAllFails) = result.failed_expectations.partition {|e| e.globalErrorType == 'load' }
          report_global_failures('Error during loading', loadFails)
          report_global_failures('Error occurred in afterAll', afterAllFails)
        end

        result
      end

      def report_global_failures(prefix, fails)
        if fails.size > 0
          fail_result = Jasmine::Result.new('fullName' => prefix, 'description' => '', 'failedExpectations' => fails)
          outputter.puts(failure_message(fail_result))
          outputter.puts
        end
      end

      def chars(results)
        results.map do |result|
          if result.succeeded?
            colored(:green, '.')
          elsif result.pending?
            colored(:yellow, '*')
          elsif result.disabled?
            ""
          else
            colored(:red, 'F')
          end
        end.join('')
      end

      def pluralize(count, str)
        word = (count == 1) ? str : str + 's'
        "#{count} #{word}"
      end

      def pending_message(spec)
        reason = 'No reason given'
        reason = spec.pending_reason if spec.pending_reason && spec.pending_reason != ''

        "\t#{spec.full_name}\n\t  #{colored(:yellow, reason)}"
      end

      def failure_message(failure)
        failure.full_name + "\n" + failure.failed_expectations.map { |fe| expectation_message(fe) }.join("\n")
      end

      def expectation_message(expectation)
        <<-FE
  Message:
      #{colored(:red, expectation.message)}
  Stack:
      #{stack(expectation.stack)}
        FE
      end

      def stack(stack)
        stack.split("\n").map(&:strip).join("\n      ")
      end

      def colored(color, message)
        s = case color
            when :green
              "\e[32m"
            when :yellow
              "\e[33m"
            when :red
              "\e[31m"
            else
              "\e[0m"
            end

        if @config.color
          "#{s}#{message}\e[0m"
        else
          message
        end
      end
    end
  end
end
