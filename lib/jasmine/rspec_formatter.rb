require 'enumerator'

module Jasmine
  class RspecFormatter
    attr_accessor :suites

    def initialize(config)
      @config = config
      @spec_files = config.spec_files
      @spec_ids = []
    end

    def start
      start_jasmine_server
      @client = Jasmine::SeleniumDriver.new(browser, "#{jasmine_host}:#{port}/")
      @client.connect
      load_suite_info
      wait_for_suites_to_finish_running
    end

    def stop
      @client.disconnect
    end

    def declare_suites
      me = self
      suites.each do |suite|
        declare_suite(self, suite)
      end
    end

    def declare_suite(parent, suite)
      me = self
      parent.describe suite["name"] do
        suite["children"].each do |suite_or_spec|
          type = suite_or_spec["type"]
          if type == "suite"
            me.declare_suite(self, suite_or_spec)
          elsif type == "spec"
            me.declare_spec(self, suite_or_spec)
          else
            raise "unknown type #{type} for #{suite_or_spec.inspect}"
          end
        end
      end
    end

    def declare_spec(parent, spec)
      me = self
      example_name = spec["name"]
      @spec_ids << spec["id"]
      backtrace = example_locations[parent.description + " " + example_name]
      if Jasmine::Dependencies.rspec2?
        parent.it example_name, {} do
          me.report_spec(spec["id"])
        end
      else
        parent.it example_name, {}, backtrace do
          me.report_spec(spec["id"])
        end
      end
    end

    def report_spec(spec_id)
      spec_results = results_for(spec_id)
      out = ""
      messages = spec_results['messages'].each do |message|
        case
          when message["type"] == "log"
            puts message["text"]
            puts "\n"
          else
            unless message["message"] =~ /^Passed.$/
              STDERR << message["message"]
              STDERR << "\n"

              out << message["message"]
              out << "\n"
            end

            if !message["passed"] && message["trace"]["stack"]
              stack_trace = message["trace"]["stack"].gsub(/<br \/>/, "\n").gsub(/<\/?b>/, " ")
              STDERR << stack_trace.gsub(/\(.*\)@http:\/\/localhost:[0-9]+\/specs\//, "/spec/")
              STDERR << "\n"
            end
        end

      end
      fail out unless spec_results['result'] == 'passed'
      puts out unless out.empty?
    end

    private

    def eval_js(script)
      @client.eval_js(script)
    end

    def json_generate(obj)
      @client.json_generate(obj)
    end

    def script_path
      File.expand_path(__FILE__)
    end

    def load_suite_info
      started = Time.now
      while !eval_js('return jsApiReporter && jsApiReporter.started') do
        raise "couldn't connect to Jasmine after 60 seconds" if (started + 60 < Time.now)
        sleep 0.1
      end

      @suites = eval_js("var result = jsApiReporter.suites(); if (window.Prototype && Object.toJSON) { return Object.toJSON(result) } else { return JSON.stringify(result) }")
    end

    def results_for(spec_id)
      @spec_results ||= load_results
      @spec_results[spec_id.to_s]
    end

    def load_results
      @spec_results = {}
      @spec_ids.each_slice(50) do |slice|
        @spec_results.merge!(eval_js("var result = jsApiReporter.resultsForSpecs(#{json_generate(slice)}); if (window.Prototype && Object.toJSON) { return Object.toJSON(result) } else { return JSON.stringify(result) }"))
      end
      @spec_results
    end

    def wait_for_suites_to_finish_running
      puts "Waiting for suite to finish in browser ..."
      while !eval_js('return jsApiReporter.finished') do
        sleep 0.1
      end
    end

    def example_locations
      return @example_locations if @example_locations
      @example_locations = {}

      example_name_parts = []
      previous_indent_level = 0
      @config.spec_files_full_paths.each do |filename|
        line_number = 1
        File.open(filename, "r") do |file|
          file.readlines.each do |line|
            match = /^(\s*)(describe|it)\s*\(\s*["'](.*)["']\s*,\s*function/.match(line)
            if (match)
              indent_level = match[1].length / 2
              example_name = match[3]
              example_name_parts[indent_level] = example_name

              full_example_name = example_name_parts.slice(0, indent_level + 1).join(" ")
              @example_locations[full_example_name] = "#{filename}:#{line_number}: in `it'"
            end
            line_number += 1
          end
        end
      end
      @example_locations
    end

    def browser
      ENV["JASMINE_BROWSER"] || 'firefox'
    end

    def jasmine_host
      ENV["JASMINE_HOST"] || 'http://localhost'
    end

    def port
      @port ||= ENV["JASMINE_PORT"] || Jasmine::find_unused_port
    end

    def start_jasmine_server
      require 'json'
      port_for_thread = port
      t = Thread.new do
        begin
          Jasmine::Server.new(port_for_thread, Jasmine::Application.app(@config)).start
        rescue ChildProcess::TimeoutError; end
        #ignore bad exits
      end
      t.abort_on_exception = true
      Jasmine::wait_for_listener(port, "jasmine server")
      puts "jasmine server started."
    end

    def windows?
      require 'rbconfig'
      ::RbConfig::CONFIG['host_os'] =~ /mswin|mingw/
    end

  end
end
