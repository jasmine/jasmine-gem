module Jasmine
  module Formatters
    class BaseFormatter < Struct.new(:results)
      def format
        raise NotImplementedError.new('You must override the summary method on any custom formatters.')
      end
    end
  end
end