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
      begin
        Bundler.with_clean_env do
          open('spec/javascripts/failing_spec.js', 'w') { |f|
            f.puts <<-FAILING_SPEC
describe("failing", function() {
  it('should fail', function() {
    expect(true).toBe(false);
  });
});
FAILING_SPEC
            f.flush
          }
          output = `bundle exec rake jasmine:ci`
          $?.should_not be_success
          output.should include('6 specs, 1 failure')
        end
      ensure
        FileUtils.rm_f(File.join('spec', 'javascripts', 'failing_spec.js'))
      end
    end

    it "runs specs written in coffeescript" do
      begin
        support_path = File.join('spec', 'javascripts', 'support')
        FileUtils.cp(File.join(@root, 'spec', 'fixture', 'coffee_spec.coffee'), File.join('spec', 'javascripts'))
        FileUtils.mv(File.join(support_path, 'jasmine.yml'), File.join(support_path, 'original_jasmine.yml'))
        jasmine_config = YAML.load_file(File.join(support_path, 'original_jasmine.yml'))
        jasmine_config['spec_files'] << 'coffee_spec.coffee'
        File.open(File.join(support_path, 'jasmine.yml'), 'w') do |f|
          f.write YAML.dump(jasmine_config)
          f.flush
        end

        Bundler.with_clean_env do
          output = `bundle exec rake jasmine:ci`
          output.should include('6 specs, 0 failures')
        end
      ensure
        FileUtils.rm_f(File.join(support_path, 'jasmine.yml'))
        FileUtils.mv(File.join(support_path, 'original_jasmine.yml'), File.join(support_path, 'jasmine.yml'))
      end
    end

    it "rake jasmine runs and serves the expected webpage when using asset pipeline" do
      open('app/assets/stylesheets/foo.css', 'w') { |f|
        f.puts "/* hi dere */"
        f.flush
      }

      jasmine_yml_path = 'spec/javascripts/support/jasmine.yml'
      jasmine_config = YAML.load_file(jasmine_yml_path)
      jasmine_config['src_files'] = ['assets/application.js']
      jasmine_config['stylesheets'] = ['assets/application.css']
      open(jasmine_yml_path, 'w') { |f|
        f.puts YAML.dump(jasmine_config)
        f.flush
      }

      Bundler.with_clean_env do
        begin
          pid = IO.popen("bundle exec rake jasmine").pid
          Jasmine::wait_for_listener(8888, 'jasmine server', 60)
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
  end
end
