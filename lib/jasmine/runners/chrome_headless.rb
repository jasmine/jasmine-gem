# require 'phantomjs'
require "socket"

module Jasmine
  module Runners
    class ChromeHeadless
      def initialize(formatter, jasmine_server_url, config)
        @formatter = formatter
        @jasmine_server_url = jasmine_server_url
        @config = config
        @show_console_log = @config.show_console_log
        @show_full_stack_trace = @config.show_full_stack_trace
        @cli_options = @config.chrome_cli_options || {}
      end

      def run
        chrome_server = IO.popen("\"#{chrome_binary}\" #{cli_options_string}")
        wait_for_chrome_to_start_debug_socket

        begin
          require "chrome_remote"
        rescue LoadError => e
          raise 'Add "chrome_remote" you your Gemfile. To use chromeheadless we require this gem.'
        end

        chrome = ChromeRemote.client
        chrome.send_cmd "Runtime.enable"
        chrome.send_cmd "Page.navigate", url: jasmine_server_url
        result_recived = false
        run_details = { 'random' => false }
        chrome.on "Runtime.consoleAPICalled" do |params|
          if params["type"] == "log"
            if params["args"][0] && params["args"][0]["value"] == "jasmine_spec_result"
              results = JSON.parse(params["args"][1]["value"], :max_nesting => false)
                            .map { |r| Result.new(r.merge!("show_full_stack_trace" => @show_full_stack_trace)) }
              formatter.format(results)
            elsif params["args"][0] && params["args"][0]["value"] == "jasmine_suite_result"
              results = JSON.parse(params["args"][1]["value"], :max_nesting => false)
                            .map { |r| Result.new(r.merge!("show_full_stack_trace" => @show_full_stack_trace)) }
              failures = results.select(&:failed?)
              if failures.any?
                formatter.format(failures)
              end
            elsif params["args"][0] && params["args"][0]["value"] == "jasmine_done"
              result_recived = true
              run_details = JSON.parse(params["args"][1]["value"], :max_nesting => false)
            elsif show_console_log
              puts params["args"].map { |e| e["value"] }.join(' ')
            end
          end
        end

        chrome.listen_until {|msg| result_recived }
        formatter.done(run_details)
        chrome.send_cmd "Browser.close"
        Process.kill("INT", chrome_server.pid)
      end

      def chrome_binary
        config.chrome_binary || find_chrome_binary
      end

      def find_chrome_binary
        path = [
          "/usr/bin/google-chrome",
          "/usr/bin/google-chrome-stable",
          "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        ].detect { |path|
          File.file?(path)
        }
        raise "No Chrome binary found" if path.nil?
        path
      end

      def cli_options_string
        @cli_options.
            map {|(k, v)| if v then "--#{k}=#{v}" else "--#{k}" end }.
            join(' ')
      end

      def wait_for_chrome_to_start_debug_socket
        time = Time.now
        while Time.now - time < config.chrome_startup_timeout
          begin;
            conn = TCPSocket.new('localhost', 9222);
          rescue SocketError;
            sleep 0.1
            next
          rescue Errno::ECONNREFUSED;
            sleep 0.1
            next
          rescue Errno::EADDRNOTAVAIL;
            sleep 0.1
            next
          else;
            conn.close;
            return
          end
        end
        raise "Chrome did't seam to start the webSocketDebugger at port: 9222, timeout #{config.chrome_startup_timeout}sec"
      end

      def boot_js
        File.expand_path('chromeheadless_boot.js', File.dirname(__FILE__))
      end

      private
      attr_reader :formatter, :jasmine_server_url, :show_console_log, :config
    end
  end
end
