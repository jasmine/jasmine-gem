module Jasmine
  module Formatters
    class Multi
      def initialize(formatters)
        @formatters = formatters
      end

      def format(results)
        go(:format, results)
      end

      def done
        go(:done)
      end

      private

      def go(method, *args)
        (@formatters || []).each do |formatter|
          formatter.public_send(method, *args)
        end
      end
    end
  end
end
