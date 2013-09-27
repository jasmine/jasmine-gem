module Jasmine
  module Formatters
    class ExitCode
      def initialize
        @results = []
      end

      def format(results)
        @results += results
      end

      def done
      end

      def exit_code
        @results.detect(&:failed?) ? 1 : 0
      end
    end
  end
end

