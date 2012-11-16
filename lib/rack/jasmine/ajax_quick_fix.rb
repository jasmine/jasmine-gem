module Rack
  module Jasmine

    class AjaxQuickFix
      def call(env)
        env["REQUEST_METHOD"] = 'GET' if env["REQUEST_METHOD"] == "POST"
        [404,{}, [] ]
      end
    end

  end
end