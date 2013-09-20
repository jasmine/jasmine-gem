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
        command = "#{Phantomjs.path} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_run.js')}' #{config.host}:#{config.port}/ #{config.result_batch_size}"
        all_raw_results = []
        IO.popen(command) do |output|
          output.each do |line|
            raw_results = JSON.parse(line, :max_nesting => false)
            line_results = Jasmine::Results.new(raw_results)
            formatter.format(line_results)
            all_raw_results += raw_results
          end
        end
        @results = Jasmine::Results.new(all_raw_results)
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
