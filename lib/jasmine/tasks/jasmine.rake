namespace :jasmine do
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

  desc "Run continuous integration tests"
  task :ci => ["jasmine:require_json", "jasmine:require"] do
    if Jasmine::Dependencies.rspec2?
      require "rspec"
      require "rspec/core/rake_task"
    else
      require "spec"
      require 'spec/rake/spectask'
    end

    if Jasmine::Dependencies.rspec2?
      RSpec::Core::RakeTask.new(:jasmine_continuous_integration_runner) do |t|
        t.rspec_opts = ["--colour", "--format", ENV['JASMINE_SPEC_FORMAT'] || "progress"]
        t.verbose = true
        if Jasmine::Dependencies.rails_3_asset_pipeline?
          t.rspec_opts += ["-r #{File.expand_path(File.join(::Rails.root, 'config', 'environment'))}"]
        end
        t.pattern = [Jasmine.runner_filepath]
      end
    else
      Spec::Rake::SpecTask.new(:jasmine_continuous_integration_runner) do |t|
        t.spec_opts = ["--color", "--format", ENV['JASMINE_SPEC_FORMAT'] || "specdoc"]
        t.verbose = true
        t.spec_files = [Jasmine.runner_filepath]
      end
    end
    Rake::Task["jasmine_continuous_integration_runner"].invoke
  end

  task :server => "jasmine:require" do
    jasmine_config_overrides = File.join(Jasmine::Config.new.project_root, 'spec', 'javascripts' ,'support' ,'jasmine_config.rb')
    require jasmine_config_overrides if File.exist?(jasmine_config_overrides)

    port = ENV['JASMINE_PORT'] || 8888
    puts "your tests are here:"
    puts "  http://localhost:#{port}/"
    Jasmine::Server.new(port).start
  end
end

desc "Run specs via server"
task :jasmine => ['jasmine:server']
