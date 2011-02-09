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

      config.before_configuration do
        old_jasmine_rakefile = ::Rails.root.join('lib', 'tasks', 'jasmine.rake')
        if old_jasmine_rakefile.exist?
          raise RuntimeError.new(
            "You no longer need to have jasmine.rake in your project, as it is now automatically loaded " +
            "from the Jasmine gem. Please delete '#{old_jasmine_rakefile}' before continuing."
          )
        end
      end

      rake_tasks do
        load "jasmine/tasks/jasmine.rake"
      end
    end
  end
end