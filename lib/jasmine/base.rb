require 'socket'
require 'erb'

module Jasmine
  # this seemingly-over-complex method is necessary to get an open port on at least some of our Macs
  def self.open_socket_on_unused_port
    infos = Socket::getaddrinfo("localhost", nil, Socket::AF_UNSPEC, Socket::SOCK_STREAM, 0, Socket::AI_PASSIVE)
    families = Hash[*infos.collect { |af, *_| af }.uniq.zip([]).flatten]

    return TCPServer.open('0.0.0.0', 0) if families.has_key?('AF_INET')
    return TCPServer.open('::', 0) if families.has_key?('AF_INET6')
    return TCPServer.open(0)
  end

  def self.find_unused_port
    socket = open_socket_on_unused_port
    port = socket.addr[1]
    socket.close
    port
  end

  def self.server_is_listening_on(hostname, port)
    require 'socket'
    begin
      socket = TCPSocket.open(hostname, port)
    rescue Errno::ECONNREFUSED
      return false
    end
    socket.close
    true
  end

  def self.wait_for_listener(port, name = "required process", seconds_to_wait = 10)
    time_out_at = Time.now + seconds_to_wait
    until server_is_listening_on "localhost", port
      sleep 0.1
      puts "Waiting for #{name} on #{port}..."
      raise "#{name} didn't show up on port #{port} after #{seconds_to_wait} seconds." if Time.now > time_out_at
    end
  end

  def self.rspec2?
    Gem::Specification::find_by_name "rspec", ">= 2.0"
  rescue Gem::LoadError
    Gem.available? "rspec", ">= 2.0"
  end

  def self.rails3?
    return Rails.version.split(".").first.to_i == 3 if defined? Rails
    begin
      Gem::Specification::find_by_name "rails", ">= 3.0"
    rescue Gem::LoadError
      Gem.available? "rails", ">= 3.0"
    end
  end
end
