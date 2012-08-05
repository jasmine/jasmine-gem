require File.join(File.dirname(__FILE__), "client")
require File.join(File.dirname(__FILE__), "server")
require 'multi_json'

module Jasmine::Drivers
  class Phantomjs
    class Browser
      attr_reader :client, :server, :logger
      def initialize(options)
        @logger = options.delete(:logger)
        @options = options
        @server = Server.new(30) # 30 is default timeout
        @client = Client.start(server.port, :path => options[:phantomjs_path])
      end

      def visit(url, headers={})
        command 'visit', url, headers
      end

      def evaluate(script)
        command 'evaluate', script
      end

      def restart
        server.restart
        client.restart
      end

      def command(name, *args)
        message = { 'name' => name, 'args' => args }
        log message.inspect

        json = JSON.load(server.send(JSON.dump(message)))
        log json.inspect

        if json['error']
          if json['error']['name'] == 'Poltergeist.JavascriptError'
            raise JavascriptError.new(json['error'])
          else
            raise BrowserError.new(json['error'])
          end
        end
        json['response']

      rescue DeadClient
        restart
        raise
      end

      private

      def log(message)
        logger.puts message if logger
      end
    end
  end
end

