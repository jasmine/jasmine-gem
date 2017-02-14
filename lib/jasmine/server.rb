module Jasmine
  class Server
    def initialize(port = 8888, application = nil, rack_options = nil, env = ENV)
      @port = port
      @application = application
      @rack_options = rack_options || {}
      @env = env
    end

    def start
      @env['PORT'] = @port.to_s
      if Jasmine::Dependencies.legacy_rack?
        handler = Rack::Handler.get('webrick')
        handler.run(@application, :Port => @port, :AccessLog => [])
      else
        server = Rack::Server.new(@rack_options.merge(:Port => @port, :AccessLog => []))
        # workaround for Rack bug, when Rack > 1.2.1 is released Rack::Server.start(:app => Jasmine.app(self)) will work
        server.instance_variable_set(:@app, @application)
        server.start
      end
    end
  end
end
