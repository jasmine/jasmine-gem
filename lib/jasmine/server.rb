require 'rack'
require 'rack/utils'
require 'jasmine-core'
require 'rack/jasmine/run_adapter'
require 'rack/jasmine/focused_suite'
require 'rack/jasmine/redirect'
require 'rack/jasmine/cache_control'

module Jasmine
  def self.app(config)
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
          Rack::Jasmine::RunAdapter.new(config)
        ])
      end
    end
  end
end
