if Rake.application.tasks.any? {|t| t.name == 'jasmine/ci' }
  message = <<-EOF

                        WARNING
Detected that jasmine rake tasks have been loaded twice.
This will cause the 'rake jasmine:ci' and 'rake jasmine' tasks to fail.

To fix this problem, you should ensure that you only load 'jasmine/tasks/jasmine.rake'
once. This should be done for you automatically if you installed jasmine's rake tasks
with either 'jasmine init' or 'rails g jasmine:install'.


EOF
  raise Exception.new(message)
end

namespace :jasmine do
  task :configure do
    require 'jasmine/config'

    begin
      Jasmine.load_configuration_from_yaml(ENV['JASMINE_CONFIG_PATH'])
    rescue Jasmine::ConfigNotFound => e
      puts e.message
      exit 1
    end
  end

  task :require do
    require 'jasmine'
  end

  task :require_json do
    begin
      require 'json'
    rescue LoadError
      puts "You must have a JSON library installed to run jasmine:ci. Try \"gem install json\""
      exit
    end
  end

  task :configure_plugins

  desc 'Run continuous integration tests'
  task :ci => %w(jasmine:require_json jasmine:require jasmine:configure jasmine:configure_plugins) do
    config = Jasmine.config

    formatters = config.formatters.map { |formatter_class| formatter_class.new }

    exit_code_formatter = Jasmine::Formatters::ExitCode.new
    formatters << exit_code_formatter

    url = "#{config.host}:#{config.port(:ci)}/"
    runner = config.runner.call(Jasmine::Formatters::Multi.new(formatters), url)
    if runner.respond_to?(:boot_js)
      config.runner_boot_dir = File.dirname(runner.boot_js)
      config.runner_boot_files = lambda { [runner.boot_js] }
    end

    server = Jasmine::Server.new(config.port(:ci), Jasmine::Application.app(config), config.rack_options)
    t = Thread.new do
      server.start
    end
    t.abort_on_exception = true
    Jasmine::wait_for_listener(config.port(:ci), 'jasmine server')
    puts 'jasmine server started.'

    runner.run

    exit(1) unless exit_code_formatter.succeeded?
  end

  task :server => %w(jasmine:require jasmine:configure jasmine:configure_plugins) do
    config = Jasmine.config
    port = config.port(:server)
    server = Jasmine::Server.new(port, Jasmine::Application.app(Jasmine.config), config.rack_options)
    puts "your server is running here: http://localhost:#{port}/"
    puts "your tests are here:         #{config.spec_dir}"
    puts "your source files are here:  #{config.src_dir}"
    puts ''
    server.start
  end
end

desc 'Run specs via server:ci'
task :jasmine => %w(jasmine:server)
