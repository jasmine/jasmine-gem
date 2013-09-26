namespace :jasmine do
  require 'jasmine/config'

  Jasmine.load_configuration_from_yaml

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

  desc 'Run continuous integration tests'
  task :ci => %w(jasmine:require_json jasmine:require) do
    Jasmine.load_configuration_from_yaml

    config = Jasmine.config

    server = Jasmine::Server.new(config.port, Jasmine::Application.app(config))
    t = Thread.new do
      begin
        server.start
      rescue ChildProcess::TimeoutError
      end
      # # ignore bad exits
    end
    t.abort_on_exception = true
    Jasmine::wait_for_listener(config.port, 'jasmine server')
    puts 'jasmine server started.'

    formatters = config.formatters.map { |formatter_class| formatter_class.new(config) }

    exit_code_formatter = Jasmine::Formatters::ExitCode.new(config)
    formatters << exit_code_formatter

    url = "#{config.host}:#{config.port}/"
    runner = config.runner.call(Jasmine::Formatters::Multi.new(formatters), url)
    runner.run

    exit exit_code_formatter.exit_code
  end

  task :server => 'jasmine:require' do
    port = Jasmine.config.jasmine_port || 8888
    puts 'your tests are here:'
    puts "  http://localhost:#{port}/"
    app = Jasmine::Application.app(Jasmine.config)
    Jasmine::Server.new(port, app).start
  end
end

desc 'Run specs via server'
task :jasmine => %w(jasmine:server)
