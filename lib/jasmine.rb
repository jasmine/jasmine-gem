jasmine_files = ['base',
                 'dependencies',
                 'runner_config',
                 'config',
                 'application',
                 'server',
                 'selenium_driver',
                 'rspec_formatter',
                 'command_line_tool',
                 'page',
                 'asset_pipeline_mapper',
                 'results_processor',
                 'results',
                 File.join('runners', 'http')]

jasmine_files.each do |file|
  require File.join('jasmine', file)
end

require File.join('jasmine', "railtie") if Jasmine::Dependencies.rails3?


