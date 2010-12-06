require 'rails'

module Jasmine
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load "jasmine/tasks/jasmine.rake"
    end
  end
end
