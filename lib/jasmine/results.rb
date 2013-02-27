module Jasmine
  class Results
    def initialize(raw_results)
      @results = raw_results.map {|raw| Result.new(raw) }
    end

    def failures
      @results.select { |result|
        result.status == "failed"
      }
    end

    def size
      @results.size
    end

    class Result < OpenStruct
      def full_name
        fullName
      end

      def failed_expectations
        failedExpectations.map { |e|
          OpenStruct.new(:message => e["message"], :stack_trace => e["trace"]["stack"])
        }
      end
    end
  end
end
