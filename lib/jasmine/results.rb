module Jasmine
  class Results
    attr_reader :results

    def initialize(raw_results)
      @results = raw_results.map {|raw| Result.new(raw) }
    end

    def failures
      @results.select { |result|
        result.status == "failed"
      }
    end

    def pending_specs
      @results.select { |result|
        result.status == "pending"
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
          short_stack = e["stack"].split("\n").slice(0, 7).join("\n")
          OpenStruct.new(:message => e["message"], :stack => short_stack)
        }
      end
    end
  end
end
