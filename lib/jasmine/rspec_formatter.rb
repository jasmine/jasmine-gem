require 'enumerator'

module Jasmine
  class RspecFormatter
    def initialize(config)
      @config = config
      @spec_files = config.spec_files
    end

    def format_results(results)
      @results = results
      declare_suites(@results.suites)
    end

    def declare_suites(suites)
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

    def results_for(spec_id)
      @results.for_spec_id(spec_id.to_s)
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

  end
end
