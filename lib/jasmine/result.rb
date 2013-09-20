module Jasmine
  class Result

    def self.map_raw_results(raw_results)
      raw_results.map { |r| new(r) }
    end

    def initialize(attrs)
      @status = attrs["status"]
      @full_name = attrs["fullName"]
      @description = attrs["description"]
      @failed_expectations = map_failures(attrs["failedExpectations"])
      @suite_name = full_name.slice(0, full_name.size - description.size - 1)
    end

    def succeeded?
      status == 'passed'
    end

    def failed?
      status == 'failed'
    end

    def pending?
      status == 'pending'
    end

    attr_reader :full_name, :description, :failed_expectations, :suite_name

    private
    attr_reader :status

    def map_failures(failures)
      failures.map do |e|
        short_stack = if e["stack"]
                        e["stack"].split("\n").slice(0, 7).join("\n")
                      else
                        "No stack trace present."
                      end
        Failure.new(e["message"], short_stack)
      end
    end

    class Failure < Struct.new(:message, :stack); end
  end
end
