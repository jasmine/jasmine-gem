jasmine_files = ['base',
                 'dependencies',
                 'runner_config',
                 'config',
                 'server',
                 'selenium_driver',
                 'spec_builder',
                 'command_line_tool',
                 'page',
                 'asset_pipeline_mapper']

jasmine_files.each do |file|
  require File.join('jasmine', file)
end

require File.join('jasmine', "railtie") if Jasmine::Dependencies.rails3?


