module Rack
  module Jasmine

    class Redirect
      def initialize(url)
        @url = url
      end

      def call(env)
        [
          302,
          { 'Location' => @url },
          []
        ]
      end
    end

  end
end

