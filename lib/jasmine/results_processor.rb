module Jasmine
  class ResultsProcessor

    def initialize(config)
      @config = config
    end

    def process(results_hash, suites_hash)
      return Jasmine::Results.new(results_hash, suites_hash, example_locations)
    end

    def example_locations
      @suite_parser ||= parse_suite
    end

    private

    def parse_suite
      require 'jasmine-parser'
      JasmineParser::Config.logging=[:info, :error]

      suite = JasmineParser::JasmineSuite.new
      parser = JasmineParser::FileParser.new(suite)


      parser.parse @config.spec_files.call

      suite
    end

  end
end
