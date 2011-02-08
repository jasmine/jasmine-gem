jasmine_files = ['base',
                 'config',
                 'server',
                 'selenium_driver',
                 'spec_builder',
                 'command_line_tool']

jasmine_files << 'generator' if Gem.available? "rails", ">= 3.0"

jasmine_files.each do |file|
  require File.join('jasmine', file)
end

if Jasmine.rails3?
  module Jasmine
    class Railtie < Rails::Railtie
      rake_tasks do
        load "jasmine/tasks/jasmine.rake"
      end
    end
  end
end