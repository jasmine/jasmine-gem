jasmine_files = ['base',
                 'dependencies',
                 'core_configuration',
                 'configuration',
                 'config',
                 'application',
                 'server',
                 'command_line_tool',
                 'page',
                 'path_mapper',
                 'asset_bundle',
                 'asset_pipeline_mapper',
                 'asset_expander',
                 'result',
                 'path_expander',
                 'yaml_config_parser',
                 File.join('formatters', 'exit_code'),
                 File.join('formatters', 'console'),
                 File.join('formatters', 'multi'),
                 File.join('runners', 'phantom_js'),
                ]


jasmine_files.each do |file|
  require File.join('jasmine', file)
end

if Jasmine::Dependencies.rails?
  require File.join('jasmine', 'railtie')
end


