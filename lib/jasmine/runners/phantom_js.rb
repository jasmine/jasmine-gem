require 'phantomjs'

module Jasmine
  module Runners
    class PhantomJs
      def initialize(formatter, config)
        @formatter = formatter
        @config = config
        @results = Jasmine::Results.new([])
      end

      def run
        command = "#{Phantomjs.path} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_run.js')}' #{config.host}:#{config.port}/"
        result_str = `#{command}`

        @results = Jasmine::Results.new(JSON.parse(result_str))
        formatter.format(@results)
        formatter.done
      end

      def succeeded?
        results.failures.count == 0
      end

      private
      attr_reader :formatter, :config, :results
    end
  end
end
