require File.join('jasmine', 'version')

jasmine_files = ['base',
                 'config',
                 'server',
                 "dependencies_#{Jasmine::RUBYGEMS_VERSION}",
                 'selenium_driver',
                 'spec_builder',
                 'command_line_tool']

jasmine_files.each do |file|
  require File.join('jasmine', file)
end

require File.join('jasmine', "railtie") if Jasmine::Dependencies.rails3?
