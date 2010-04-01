require File.expand_path('../../.bundle/environment', __FILE__)
Bundler.require(:default, :test)

require 'spec'

require File.expand_path(File.join(File.dirname(__FILE__), "../lib/jasmine"))
