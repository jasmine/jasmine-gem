require 'spec_helper'
require 'net/http'
require 'yaml'

if Jasmine::Dependencies.rails_available?
  describe 'A Rails app' do
    def bundle_install
      tries_remaining = 3
      while tries_remaining > 0
        puts `NOKOGIRI_USE_SYSTEM_LIBRARIES=true bundle install --path vendor;`
        if $?.success?
          tries_remaining = 0
        else
          tries_remaining -= 1
          puts "\n\nBundle failed, trying #{tries_remaining} more times\n\n"
        end
      end
    end

    before :all do
      temp_dir_before
      Dir::chdir @tmp

      create_rails 'rails-example'
      Dir::chdir File.join(@tmp, 'rails-example')

      base = File.absolute_path(File.join(__FILE__, '../..'))

      open('Gemfile', 'a') { |f|
        f.puts "gem 'jasmine', :path => '#{base}'"
        f.puts "gem 'jasmine-core', :github => 'pivotal/jasmine'"
        f.puts "gem 'rubysl', :platform => :rbx"
        f.puts "gem 'racc', :platform => :rbx"
        f.flush
      }

      Bundler.with_clean_env do
        bundle_install
        `bundle exec rails g jasmine:install`
        File.exists?('spec/javascripts/helpers/.gitkeep').should == true
        File.exists?('spec/javascripts/support/jasmine.yml').should == true
        `bundle exec rails g jasmine:examples`
        File.exists?('app/assets/javascripts/jasmine_examples/Player.js').should == true
        File.exists?('app/assets/javascripts/jasmine_examples/Song.js').should == true
        File.exists?('spec/javascripts/jasmine_examples/PlayerSpec.js').should == true
        File.exists?('spec/javascripts/helpers/jasmine_examples/SpecHelper.js').should == true
      end
    end

    after :all do
      temp_dir_after
    end

    it 'should have the jasmine & jasmine:ci rake task' do
      #See https://github.com/jimweirich/rake/issues/220 and https://github.com/jruby/activerecord-jdbc-adapter/pull/467
      #There's a workaround, but requires setting env vars & jruby opts (non-trivial when inside of a jruby process), so skip for now.
      pending "activerecord-jdbc + rake -T doesn't work correctly under Jruby" if ENV['RAILS_VERSION'] == 'rails3' && RUBY_PLATFORM == 'java'
      Bundler.with_clean_env do
        output = `bundle exec rake -T`
        output.should include('jasmine ')
        output.should include('jasmine:ci')
      end
    end

    it "rake jasmine:ci runs and returns expected results" do
      Bundler.with_clean_env do
        output = `bundle exec rake jasmine:ci`
        output.should include('5 specs, 0 failures')
      end
    end

    it "rake jasmine:ci returns proper exit code when specs fail" do
      Bundler.with_clean_env do
        FileUtils.cp(File.join(@root, 'spec', 'fixture', 'failing_test.js'), File.join('spec', 'javascripts'))
        failing_yaml = custom_jasmine_config('failing') do |jasmine_config|
          jasmine_config['spec_files'] << 'failing_test.js'
        end
        output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{failing_yaml}`
        $?.should_not be_success
        output.should include('6 specs, 1 failure')
      end
    end

    it "runs specs written in coffeescript" do
      coffee_yaml = custom_jasmine_config('coffee') do |jasmine_config|
        jasmine_config['spec_files'] << 'coffee_spec.coffee'
      end
      FileUtils.cp(File.join(@root, 'spec', 'fixture', 'coffee_spec.coffee'), File.join('spec', 'javascripts'))

      Bundler.with_clean_env do
        output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{coffee_yaml}`
        output.should include('6 specs, 0 failures')
      end
    end

    it "rake jasmine runs and serves the expected webpage when using asset pipeline" do
      open('app/assets/stylesheets/foo.css', 'w') { |f|
        f.puts "/* hi dere */"
        f.flush
      }

      css_yaml = custom_jasmine_config('css') do |jasmine_config|
        jasmine_config['src_files'] = ['assets/application.js']
        jasmine_config['stylesheets'] = ['assets/application.css']
      end

      Bundler.with_clean_env do
        begin
          pid = IO.popen("bundle exec rake jasmine JASMINE_CONFIG_PATH=#{css_yaml}").pid
          Jasmine::wait_for_listener(8888, 'jasmine server', 60)

          # if the process we started is not still running, it's very likely this test
          # will fail because another server is already running on port 8888
          # (kill -0 will check if you can send *ANY* signal to this process)
          # (( it does not actually kill the process, that happens below))
          `kill -0 #{pid}`
          unless $?.success?
            puts "someone else is running a server on port 8888"
            $?.should be_success
          end

          output = Net::HTTP.get(URI.parse('http://localhost:8888/'))
          output.should match(%r{script src.*/assets/jasmine_examples/Player.js})
          output.should match(%r{script src.*/assets/jasmine_examples/Song.js})
          output.should match(%r{<link rel=.stylesheet.*?href=./assets/foo.css\?.*?>})
        ensure
          Process.kill(:SIGINT, pid)
          begin
            Process.waitpid pid
          rescue Errno::ECHILD
          end
        end
      end
    end

    it "should load js files outside of the assets path too" do
      yaml = custom_jasmine_config('public-assets') do |jasmine_config|
        jasmine_config['src_files'] << 'public/javascripts/**/*.js'
        jasmine_config['spec_files'] = ['non_asset_pipeline_test.js']
      end
      FileUtils.mkdir_p(File.join('public', 'javascripts'))
      FileUtils.cp(File.join(@root, 'spec', 'fixture', 'non_asset_pipeline.js'), File.join('public', 'javascripts'))
      FileUtils.cp(File.join(@root, 'spec', 'fixture', 'non_asset_pipeline_test.js'), File.join('spec', 'javascripts'))

      Bundler.with_clean_env do
        output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{yaml}`
        output.should include('1 spec, 0 failures')
      end
    end
  end
end
