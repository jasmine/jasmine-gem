module Jasmine
  class Server
    def initialize(port = 8888, application = nil, rack_options = nil)
      @port = port
      @application = application
      @rack_options = rack_options || {}
      @host = rack_options[:Host] ? rack_options[:Host] : 'localhost' 
    end

    def start
      if Jasmine::Dependencies.legacy_rack?
        handler = Rack::Handler.get('webrick')
        handler.run(@application, :Port => @port, :AccessLog => [], :Host => @host)
      else
        server = Rack::Server.new(@rack_options.merge(:Port => @port, :AccessLog => [], :Host => @host))
        # workaround for Rack bug, when Rack > 1.2.1 is released Rack::Server.start(:app => Jasmine.app(self)) will work
        server.instance_variable_set(:@app, @application)
        server.start
      end
    end
  end
end
