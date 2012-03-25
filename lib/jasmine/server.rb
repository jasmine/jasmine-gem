require 'rack'
require 'rack/utils'
require 'jasmine-core'

module Jasmine
  class RunAdapter
    def initialize(config)
      @config = config
      @jasmine_files = Jasmine::Core.js_files.map {|f| "/__JASMINE_ROOT__/#{f}"}
      @jasmine_stylesheets = Jasmine::Core.css_files.map {|f| "/__JASMINE_ROOT__/#{f}"}
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
      body = ERB.new(File.read(File.join(File.dirname(__FILE__), "run.html.erb"))).result(binding)
      [
        200,
        { 'Content-Type' => 'text/html', 'Pragma' => 'no-cache' },
        [body]
      ]
    end
  end

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

  class JsAlert
    def call(env)
      [
        200,
        { 'Content-Type' => 'application/javascript' },
        ["document.write('<p>Couldn\\'t load #{env["PATH_INFO"]}!</p>');"]
      ]
    end
  end

  class FocusedSuite
    def initialize(config)
      @config = config
    end

    def call(env)
      run_adapter = Jasmine::RunAdapter.new(@config)
      run_adapter.run(env["PATH_INFO"])
    end
  end

  class CacheControl
    def initialize(app)
      @app, @content_type = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      headers = Rack::Utils::HeaderHash.new(headers)
      headers['Cache-Control'] ||= "max-age=0, private, must-revalidate"
      [status, headers, body]
    end
  end


  def self.app(config)
    Rack::Builder.app do
      use Rack::Head
      use Jasmine::CacheControl
      if Jasmine::Dependencies.rails_3_asset_pipeline?
        map('/assets') do
          run Rails.application.assets
        end
      end

      map('/run.html')         { run Jasmine::Redirect.new('/') }
      map('/__suite__')        { run Jasmine::FocusedSuite.new(config) }

      map('/__JASMINE_ROOT__') { run Rack::File.new(Jasmine::Core.path) }
      map(config.spec_path)    { run Rack::File.new(config.spec_dir) }
      map(config.root_path)    { run Rack::File.new(config.project_root) }

      map('/') do
        run Rack::Cascade.new([
          Rack::URLMap.new('/' => Rack::File.new(config.src_dir)),
          Jasmine::RunAdapter.new(config)
        ])
      end
    end
  end
end
