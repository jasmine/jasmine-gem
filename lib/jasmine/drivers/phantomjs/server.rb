require File.join(File.dirname(__FILE__), "web_socket_server")
module Jasmine::Drivers
  class Phantomjs
    class Server
      attr_reader :port, :socket, :timeout

      def initialize(timeout = nil)
        server = TCPServer.new('127.0.0.1', 0)
        @port    = server.addr[1]
        @timeout = timeout
        start
      ensure
        server.close if server
      end

      def timeout=(sec)
        @timeout = @socket.timeout = sec
      end

      def start
        @socket = WebSocketServer.new(port, timeout)
      end

      def stop
        @socket.close
      end

      def restart
        stop
        start
      end

      def send(message)
        @socket.send(message) or raise DeadClient.new(message)
      end
    end
  end
end
