module Rack
  module Jasmine

    class FocusedSuite
      def initialize(config)
        @config = config
      end

      def call(env)
        run_adapter = Rack::Jasmine::RunAdapter.new(@config)
        run_adapter.run(env["PATH_INFO"])
      end
    end

  end
end

