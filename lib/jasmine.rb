jasmine_files = ['base',
                 'dependencies',
                 'core_configuration',
                 'configuration',
                 'config',
                 'application',
                 'server',
                 'selenium_driver',
                 'command_line_tool',
                 'page',
                 'path_mapper',
                 'asset_bundle',
                 'asset_pipeline_mapper',
                 'asset_expander',
                 'results',
                 'path_expander',
                 'yaml_config_parser',
                 File.join('formatters', 'base'),
                 File.join('formatters', 'console'),
                 File.join('formatters', 'junit_xml'),
                 File.join('formatters', 'multi'),
                 File.join('runners', 'http'),
                 File.join('runners', 'phantom_js'),
                 File.join('reporters', 'api_reporter')]


jasmine_files.each do |file|
  require File.join('jasmine', file)
end

if Jasmine::Dependencies.rails?
  require File.join('jasmine', 'railtie')
end


