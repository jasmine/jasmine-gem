module Jasmine
  module Formatters
    class Base
      def initialize(config)
        @config = config
      end

      def format(results)
        raise NotImplementedError.new('You must override the format method on any custom formatters.')
      end

      def done
      end

      private
      attr_reader :config
    end
  end
end
