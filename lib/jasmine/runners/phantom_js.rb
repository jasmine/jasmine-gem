require 'phantomjs'

module Jasmine
  module Runners
    class PhantomJs
      def initialize(formatter, jasmine_server_url, result_batch_size)
        @formatter = formatter
        @jasmine_server_url = jasmine_server_url
        @result_batch_size = result_batch_size
      end

      def run
        command = "#{Phantomjs.path} '#{File.join(File.dirname(__FILE__), 'phantom_jasmine_run.js')}' #{jasmine_server_url} #{result_batch_size}"
        IO.popen(command) do |output|
          output.each do |line|
            raw_results = JSON.parse(line, :max_nesting => false)
            results = raw_results.map { |r| Result.new(r) }
            formatter.format(results)
          end
        end
        formatter.done
      end

      private
      attr_reader :formatter, :jasmine_server_url, :result_batch_size
    end
  end
end

