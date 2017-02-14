require 'spec_helper'

describe Jasmine::Server do
  describe "rack ~> 1.0" do
    before do
      allow(Jasmine::Dependencies).to receive(:legacy_rack?).and_return(true)
    end

    it "should run the handler with the application" do
      server = double(:server)
      port = 1234
      fake_env = {}
      application = double(:application)
      expect(Rack::Handler).to receive(:get).with("webrick").and_return(server)
      expect(server).to receive(:run).with(application, hash_including(:Port => port))
      Jasmine::Server.new(port, application, nil, fake_env).start
      expect(fake_env['PORT']).to eq('1234')
    end
  end

  describe "rack >= 1.1" do
    before do
      allow(Jasmine::Dependencies).to receive(:legacy_rack?).and_return(false)
      if !Rack.constants.include?(:Server)
        Rack::Server = double("Rack::Server")
      end
      @fake_env = {}
    end

    it "should create a Rack::Server with the correct port when passed" do
      port = 1234
      expect(Rack::Server).to receive(:new).with(hash_including(:Port => port)).and_return(double(:server).as_null_object)
      Jasmine::Server.new(port, double(:app), nil, @fake_env).start
    end

    it "should start the server" do
      server = double(:server)
      expect(Rack::Server).to receive(:new) { server.as_null_object }
      expect(server).to receive(:start)
      Jasmine::Server.new('8888', double(:app), nil, @fake_env).start
    end

    it "should set the app as the instance variable on the rack server" do
      app = double('application')
      server = double(:server)
      expect(Rack::Server).to receive(:new) { server.as_null_object }
      Jasmine::Server.new(1234, app, nil, @fake_env).start
      expect(server.instance_variable_get(:@app)).to eq app
    end

    it "should pass rack options when starting the server" do
      app = double('application')
      expect(Rack::Server).to receive(:new).with(hash_including(:Port => 1234, :foo => 'bar')).and_return(double(:server).as_null_object)
      Jasmine::Server.new(1234, app, {:foo => 'bar', :Port => 4321}, @fake_env).start
      expect(@fake_env['PORT']).to eq('1234')
    end
  end
end
