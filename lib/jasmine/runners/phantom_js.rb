require 'phantomjs'

module Jasmine
  module Runners
    class PhantomJs
      def initialize(formatter, jasmine_server_url, result_batch_size)
        @formatter = formatter
        @jasmine_server_url = jasmine_server_url
        @result_batch_size = result_batch_size
        @results = []
      end

      def run
        command = "#{Phantomjs.path} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_run.js')}' #{jasmine_server_url} #{result_batch_size}"
        all_raw_results = []
        IO.popen(command) do |output|
          output.each do |line|
            raw_results = JSON.parse(line, :max_nesting => false)
            line_results = raw_results.map { |r| Result.new(r) }
            formatter.format(line_results)
            all_raw_results += raw_results
          end
        end
        @results = Result.map_raw_results(all_raw_results)
        formatter.done
      end

      def succeeded?
        results.count(&:failed?) == 0
      end

      private
      attr_reader :formatter, :results, :jasmine_server_url, :result_batch_size
    end
  end
end

