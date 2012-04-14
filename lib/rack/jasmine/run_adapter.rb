module Rack
  module Jasmine

    class RunAdapter
      def initialize(config)
        @config = config
        @jasmine_files = ::Jasmine::Core.js_files.map {|f| "/__JASMINE_ROOT__/#{f}"}
        @jasmine_stylesheets = ::Jasmine::Core.css_files.map {|f| "/__JASMINE_ROOT__/#{f}"}
      end

      def call(env)
        return not_found if env["PATH_INFO"] != "/"
        run
      end

      def not_found
        body = "File not found: #{@path_info}\n"
        [404, {"Content-Type" => "text/plain",
               "Content-Length" => body.size.to_s,
               "X-Cascade" => "pass"},
               [body]]
      end

      #noinspection RubyUnusedLocalVariable
      def run(focused_suite = nil)
        jasmine_files = @jasmine_files
        css_files = @jasmine_stylesheets + (@config.css_files || [])
        js_files = @config.js_files(focused_suite)
        body = ERB.new(::Jasmine.runner_template).result(binding)
        [
          200,
          { 'Content-Type' => 'text/html', 'Pragma' => 'no-cache' },
          [body]
        ]
      end
    end

  end
end
