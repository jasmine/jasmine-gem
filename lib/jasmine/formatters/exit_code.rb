module Jasmine
  module Formatters
    class ExitCode < Base

      def initialize(config)
        super
        @results = []
      end

      def format(results)
        @results += results
      end

      def exit_code
        @results.detect(&:failed?) ? 1 : 0
      end
    end
  end
end

