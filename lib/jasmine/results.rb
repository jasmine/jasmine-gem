module Jasmine
  class Results

    attr_reader :suites
    def initialize(result_hash, suite_hash)
      @suites = suite_hash
      @results = result_hash
    end

    def for_spec_id(id)
      @results[id]
    end
  end
end
