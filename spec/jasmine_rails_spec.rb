require 'spec_helper'
require 'net/http'
require 'yaml'
require 'jasmine/ruby_versions'

if rails_available?
  describe 'A Rails app' do
    def bundle_install
      bundle_output = `NOKOGIRI_USE_SYSTEM_LIBRARIES=true bundle install --path vendor --retry 3;`
      unless $?.success?
        puts bundle_output
        raise "Bundle failed to install."
      end
    end

    before :all do
      temp_dir_before
      Dir::chdir @tmp

      if ENV['RAILS_VERSION'] == 'rails6'
        `rails new rails-example --skip-bundle  --skip-active-record --skip-bootsnap --skip-webpack-install`
      else
        `rails new rails-example --skip-bundle  --skip-active-record`
      end
      Dir::chdir File.join(@tmp, 'rails-example')

      base = File.absolute_path(File.join(__FILE__, '../..'))

      open('Gemfile', 'a') { |f|
        f.puts "gem 'jasmine', :path => '#{base}'"
        f.puts "gem 'jasmine-core', :git => 'http://github.com/jasmine/jasmine.git'"
        if RUBY_PLATFORM != 'java' && ENV['RAILS_VERSION'] != 'rails5'
          f.puts "gem 'thin'"
        end
        f.puts "gem 'angularjs-rails'"
        f.flush
      }

      Bundler.with_clean_env do
        bundle_install
        `bundle exec rails g jasmine:install`
        expect($?).to eq 0
        expect(File.exists?('spec/javascripts/helpers/.gitkeep')).to eq true
        expect(File.exists?('spec/javascripts/support/jasmine.yml')).to eq true
        `bundle exec rails g jasmine:examples`
        expect(File.exists?('app/assets/javascripts/jasmine_examples/Player.js')).to eq true
        expect(File.exists?('app/assets/javascripts/jasmine_examples/Song.js')).to eq true
        expect(File.exists?('spec/javascripts/jasmine_examples/PlayerSpec.js')).to eq true
        expect(File.exists?('spec/javascripts/helpers/jasmine_examples/SpecHelper.js')).to eq true
      end

      if ENV['RAILS_VERSION'] == 'rails6'
        open('app/assets/javascripts/application.js', 'a') { |f|
          f.puts '//= require_tree .'
          f.flush
        }
      end
    end

    after :all do
      temp_dir_after
    end

    it 'should have the jasmine & jasmine:ci rake task' do
      #See https://github.com/jimweirich/rake/issues/220 and https://github.com/jruby/activerecord-jdbc-adapter/pull/467
      #There's a workaround, but requires setting env vars & jruby opts (non-trivial when inside of a jruby process), so skip for now.
      Bundler.with_clean_env do
        output = `bundle exec rake -T`
        expect(output).to include('jasmine ')
        expect(output).to include('jasmine:ci')
      end
    end

    describe "with phantomJS" do
      it "rake jasmine:ci runs and returns expected results" do
        Bundler.with_clean_env do
          output = `bundle exec rake jasmine:ci`
          expect(output).to include('5 specs, 0 failures')
        end
      end

      it "rake jasmine:ci returns proper exit code when specs fail" do
        Bundler.with_clean_env do
          FileUtils.cp(File.join(@root, 'spec', 'fixture', 'failing_test.js'), File.join('spec', 'javascripts'))
          failing_yaml = custom_jasmine_config('failing') do |jasmine_config|
            jasmine_config['spec_files'] << 'failing_test.js'
          end
          output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{failing_yaml}`
          expect($?).to_not be_success
          expect(output).to include('6 specs, 1 failure')
        end
      end

      it "rake jasmine:ci runs specs when an error occurs in the javascript" do
        Bundler.with_clean_env do
          FileUtils.cp(File.join(@root, 'spec', 'fixture', 'exception_test.js'), File.join('spec', 'javascripts'))
          exception_yaml = custom_jasmine_config('exception') do |jasmine_config|
            jasmine_config['spec_files'] << 'exception_test.js'
          end
          output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{exception_yaml}`
          expect($?).to_not be_success
          expect(output).to include('5 specs, 0 failures')
        end
      end

      it "runs specs written in coffeescript" do
        coffee_yaml = custom_jasmine_config('coffee') do |jasmine_config|
          jasmine_config['spec_files'] << 'coffee_spec.coffee'
        end
        FileUtils.cp(File.join(@root, 'spec', 'fixture', 'coffee_spec.coffee'), File.join('spec', 'javascripts'))

        Bundler.with_clean_env do
          output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{coffee_yaml}`
          expect(output).to include('6 specs, 0 failures')
        end
      end

      it "rake jasmine runs and serves the expected webpage when using asset pipeline" do
        open('app/assets/stylesheets/foo.css', 'w') { |f|
          f.puts "/* hi dere */"
          f.flush
        }

        open('spec/javascripts/helpers/angular_helper.js', 'w') { |f|
          f.puts "//= require angular-mocks"
          f.flush
        }

        css_yaml = custom_jasmine_config('css') do |jasmine_config|
          jasmine_config['src_files'] = %w[assets/application.js http://ajax.googleapis.com/ajax/libs/jquery/1.11.0/jquery.min.js]
          jasmine_config['stylesheets'] = ['assets/application.css']
        end

        run_jasmine_server("JASMINE_CONFIG_PATH=#{css_yaml}") do
          output = Net::HTTP.get(URI.parse('http://localhost:8888/'))
          expect(output).to match(%r{script src.*/assets/jasmine_examples/Player(\.self-[^\.]+)?\.js})
          expect(output).to match(%r{script src=['"]http://ajax\.googleapis\.com/ajax/libs/jquery/1\.11\.0/jquery\.min\.js})
          expect(output).to match(%r{script src.*/assets/jasmine_examples/Song(\.self-[^\.]+)?\.js})
          expect(output).to match(%r{script src.*angular_helper\.js})
          expect(output).to match(%r{<link rel=.stylesheet.*?href=./assets/foo(\.self-[^\.]+)?\.css\?.*?>})

          output = Net::HTTP.get(URI.parse('http://localhost:8888/__spec__/helpers/angular_helper.js'))
          expect(output).to match(/angular\.mock/)
        end
      end

      it "sets assets_prefix when using sprockets" do
        open('app/assets/stylesheets/assets_prefix.js.erb', 'w') { |f|
          f.puts "<%= assets_prefix %>"
          f.flush
        }

        run_jasmine_server do
          output = Net::HTTP.get(URI.parse('http://localhost:8888/assets/assets_prefix.js'))
          expect(output).to match("/assets")
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
          expect(output).to include('1 spec, 0 failures')
        end
      end

      it "should pass custom rack options from jasmine.yml" do
        pending "we're testing this with thin, which doesn't work in jruby" if RUBY_PLATFORM == 'java'
        rack_yaml = custom_jasmine_config('custom_rack') do |jasmine_config|
          jasmine_config['rack_options'] = { 'server' => 'webrick' }
        end

        Bundler.with_clean_env do
          default_output = `bundle exec rake jasmine:ci`
          if ENV['RAILS_VERSION'] == 'rails5' || ENV['RAILS_VERSION'].nil?
            expect(default_output).to include('Puma starting')
          else
            expect(default_output).to include('Thin web server')
          end

          custom_output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{rack_yaml} 2>&1`
          expect(custom_output).to include("WEBrick")
        end
      end

      describe 'using sprockets 4' do
        before :all do
          FileUtils.cp('Gemfile', 'Gemfile-old')
          FileUtils.rm 'Gemfile.lock'

          open('Gemfile', 'a') { |f|
            f.puts "gem 'sprockets', '~> 4.0.0.beta6'"
            f.flush
          }
          Bundler.with_clean_env do
            bundle_install
          end

          FileUtils.mkdir_p('app/assets/config')

          open('app/assets/config/manifest.js', 'w') { |f|
            f.puts "//= link application.js"
            f.puts "//= link application.css"
            f.flush
          }
        end

        after :all do
          FileUtils.mv 'Gemfile-old', 'Gemfile'
          FileUtils.rm 'Gemfile.lock'
          FileUtils.rm 'app/assets/config/manifest.js'
          Bundler.with_clean_env do
            bundle_install
          end
        end

        it "serves source mapped assets" do
          run_jasmine_server do
            output = Net::HTTP.get(URI.parse('http://localhost:8888/'))

            js_match = output.match %r{script src.*/(assets/application.debug-[^\.]+\.js)}

            expect(js_match).to_not be_nil
            expect(output).to match(%r{<link rel=.stylesheet.*?href=.*/assets/application.debug-[^\.]+\.css})

            js_path = js_match[1]
            output = Net::HTTP.get(URI.parse("http://localhost:8888/#{js_path}"))
            expect(output).to match(%r{//# sourceMappingURL=.*\.map})
          end
        end
      end
    end

    describe "with Chrome headless" do
      before :all do
        open('spec/javascripts/support/jasmine_helper.rb', 'w') { |f|
          f.puts "Jasmine.configure do |config|\n  config.runner_browser = :chromeheadless\nend\n"
          f.flush
        }
      end


      it "rake jasmine:ci runs and returns expected results", :focus do
        Bundler.with_clean_env do
          `bundle add chrome_remote`
          output = `bundle exec rake jasmine:ci`
          expect(output).to include('5 specs, 0 failures')
          `bundle remove chrome_remote`
        end
      end

      it "rake jasmine:ci returns proper exit code when specs fail" do
        Bundler.with_clean_env do
          `bundle add chrome_remote`

          FileUtils.cp(File.join(@root, 'spec', 'fixture', 'failing_test.js'), File.join('spec', 'javascripts'))
          failing_yaml = custom_jasmine_config('failing') do |jasmine_config|
            jasmine_config['spec_files'] << 'failing_test.js'
          end
          output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{failing_yaml}`
          expect($?).to_not be_success
          expect(output).to include('6 specs, 1 failure')
          `bundle remove chrome_remote`
        end
      end

      it "rake jasmine:ci runs specs when an error occurs in the javascript" do
        Bundler.with_clean_env do
          `bundle add chrome_remote`
          FileUtils.cp(File.join(@root, 'spec', 'fixture', 'exception_test.js'), File.join('spec', 'javascripts'))
          exception_yaml = custom_jasmine_config('exception') do |jasmine_config|
            jasmine_config['spec_files'] << 'exception_test.js'
          end
          output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{exception_yaml}`
          expect($?).to_not be_success
          expect(output).to include('5 specs, 0 failures')
          `bundle remove chrome_remote`
        end
      end

      it "runs specs written in coffeescript" do
        coffee_yaml = custom_jasmine_config('coffee') do |jasmine_config|
          jasmine_config['spec_files'] << 'coffee_spec.coffee'
        end
        FileUtils.cp(File.join(@root, 'spec', 'fixture', 'coffee_spec.coffee'), File.join('spec', 'javascripts'))

        Bundler.with_clean_env do
          `bundle add chrome_remote`
          output = `bundle exec rake jasmine:ci JASMINE_CONFIG_PATH=#{coffee_yaml}`
          expect(output).to include('6 specs, 0 failures')
          `bundle remove chrome_remote`
        end
      end
    end

    def run_jasmine_server(options = "")
      Bundler.with_clean_env do
        begin
          pid = IO.popen("bundle exec rake jasmine #{options}").pid
          Jasmine::wait_for_listener(8888, 'localhost', 60)

          # if the process we started is not still running, it's very likely this test
          # will fail because another server is already running on port 8888
          # (kill -0 will check if you can send *ANY* signal to this process)
          # (( it does not actually kill the process, that happens below))
          `kill -0 #{pid}`
          unless $?.success?
            puts "someone else is running a server on port 8888"
            expect($?).to be_success
          end
          yield
        ensure
          Process.kill(:SIGINT, pid)
          begin
            Process.waitpid pid
          rescue Errno::ECHILD
          end
        end
      end
    end
  end
end
