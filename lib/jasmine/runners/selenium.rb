module Jasmine
  module Runners
    class Selenium
      attr_accessor :suites

      def initialize(formatter, config)
        @formatter = formatter
        @config = config
      end

      def run
        start_jasmine_server
        @client = Jasmine::SeleniumDriver.new(browser, "#{jasmine_host}:#{port}/")
        @client.connect
        load_suite_info
        wait_for_suites_to_finish_running
        @formatter.format_results(results, suites)
        @client.disconnect
      end

      private

      def load_suite_info
        started = Time.now
        while !eval_js('return jsApiReporter && jsApiReporter.started') do
          raise "couldn't connect to Jasmine after 60 seconds" if (started + 60 < Time.now)
          sleep 0.1
        end

        @suites = eval_js("var result = jsApiReporter.suites(); if (window.Prototype && Object.toJSON) { return Object.toJSON(result) } else { return JSON.stringify(result) }")
      end

      def results
        spec_results = {}
        spec_ids.each_slice(50) do |slice|
          spec_results.merge!(eval_js("var result = jsApiReporter.resultsForSpecs(#{json_generate(slice)}); if (window.Prototype && Object.toJSON) { return Object.toJSON(result) } else { return JSON.stringify(result) }"))
        end
        spec_results
      end

      def spec_ids
        map_spec_ids = lambda do |suites|
          suites.map do |suite_or_spec|
            if suite_or_spec['type'] == 'spec'
              suite_or_spec['id']
            else
              map_spec_ids.call(suite_or_spec['children'])
            end
          end
        end
        map_spec_ids.call(@suites).compact.flatten
      end

      def wait_for_suites_to_finish_running
        puts "Waiting for suite to finish in browser ..."
        while !eval_js('return jsApiReporter.finished') do
          sleep 0.1
        end
      end

      def eval_js(script)
        @client.eval_js(script)
      end

      def json_generate(obj)
        @client.json_generate(obj)
      end

      def browser
        ENV["JASMINE_BROWSER"] || 'firefox'
      end

      def jasmine_host
        ENV["JASMINE_HOST"] || 'http://localhost'
      end

      def port
        @port ||= ENV["JASMINE_PORT"] || Jasmine.find_unused_port
      end

      def start_jasmine_server
        require 'json'
        port_for_thread = port
        t = Thread.new do
          begin
            Jasmine::Server.new(port, Jasmine::Application.app(@config)).start
          rescue ChildProcess::TimeoutError; end
          # # ignore bad exits
        end
        t.abort_on_exception = true
        Jasmine::wait_for_listener(port, "jasmine server")
        puts "jasmine server started."
      end

    end
  end
end
