module Jasmine
  module Formatters
    class ExitCode
      def initialize
        @result = nil
      end

      def format(results)
      end

      def done(result)
        @result = result
      end

      def succeeded?
        @result && @result['overallStatus'] == 'passed'
      end
    end
  end
end

