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
