require 'rack'
require 'rack/utils'
require 'jasmine-core'
require 'rack/jasmine/runner'
require 'rack/jasmine/focused_suite'
require 'rack/jasmine/redirect'
require 'rack/jasmine/cache_control'
require 'ostruct'

module Jasmine
  def self.app(config)
    jasmine_stylesheets = ::Jasmine::Core.css_files.map {|f| "/__JASMINE_ROOT__/#{f}"}
    config_shim = OpenStruct.new({:jasmine_files => ::Jasmine::Core.js_files.map {|f| "/__JASMINE_ROOT__/#{f}"},
                                  :js_files => config.js_files,
                                  :css_files => jasmine_stylesheets + (config.css_files || [])})
    page = Jasmine::Page.new(config_shim.instance_eval { binding })
    Rack::Builder.app do
      use Rack::Head
      use Rack::Jasmine::CacheControl
      if Jasmine::Dependencies.rails_3_asset_pipeline?
        map('/assets') do
          run Rails.application.assets
        end
      end

      map('/run.html')         { run Rack::Jasmine::Redirect.new('/') }
      map('/__suite__')        { run Rack::Jasmine::FocusedSuite.new(config) }

      map('/__JASMINE_ROOT__') { run Rack::File.new(Jasmine::Core.path) }
      map(config.spec_path)    { run Rack::File.new(config.spec_dir) }
      map(config.root_path)    { run Rack::File.new(config.project_root) }

      map('/') do
        run Rack::Cascade.new([
          Rack::URLMap.new('/' => Rack::File.new(config.src_dir)),
          Rack::Jasmine::Runner.new(page)
        ])
      end
    end
  end
end
