module Jasmine
  module Formatters
    class BaseFormatter < Struct.new(:config)
      def format(results)
        raise NotImplementedError.new('You must override the format method on any custom formatters.')
      end

      def done
      end
    end
  end
end
