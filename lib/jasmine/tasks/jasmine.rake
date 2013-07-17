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
    if Jasmine::Dependencies.rspec2?
      require 'rspec'
      require 'rspec/core/rake_task'
    else
      require 'spec'
      require 'spec/rake/spectask'
    end

    if Jasmine::Dependencies.rspec2?
      RSpec::Core::RakeTask.new(:jasmine_continuous_integration_runner) do |t|
        t.rspec_opts = ['--colour', '--format', Jasmine.config.spec_format || 'progress']
        t.verbose = true
        if Jasmine::Dependencies.use_asset_pipeline?
          t.rspec_opts += ["-r #{File.expand_path(File.join(::Rails.root, 'config', 'environment'))}"]
        end
        t.pattern = [Jasmine.runner_filepath]
      end
    else
      Spec::Rake::SpecTask.new(:jasmine_continuous_integration_runner) do |t|
        t.spec_opts = ['--color', '--format', Jasmine.config.spec_format || 'specdoc']
        t.verbose = true
        t.spec_files = [Jasmine.runner_filepath]
      end
    end
    Rake::Task['jasmine_continuous_integration_runner'].invoke
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
