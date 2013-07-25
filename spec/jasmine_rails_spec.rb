require 'spec_helper'

if Jasmine::Dependencies.rails_available?
  describe 'A Rails app' do

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
        puts `NOKOGIRI_USE_SYSTEM_LIBRARIES=true bundle install --path vendor;`
      end
    end

    after :all do
      temp_dir_after
    end

    context 'when Jasmine has been required' do
      it 'should show the Jasmine generators' do
        Bundler.with_clean_env do
          output = `bundle exec rails g`
          output.should include('jasmine:install')
          output.should include('jasmine:examples')
        end
      end

      it 'should show jasmine:install help' do
        Bundler.with_clean_env do
          output = `bundle exec rails g jasmine:install --help`
          output.should include('rails generate jasmine:install')
        end
      end

      it 'should have the jasmine rake task' do
        Bundler.with_clean_env do
          output = `bundle exec rake -T`
          output.should include('jasmine ')
        end
      end

      it 'should have the jasmine:ci rake task' do
        Bundler.with_clean_env do
          output = `bundle exec rake -T`
          output.should include('jasmine:ci')
        end
      end

      context 'and then installed' do
        before :each do
          Bundler.with_clean_env do
            @output = `bundle exec rails g jasmine:install`
          end
        end

        it 'should have the Jasmine config files' do
          @output.should include('create')

          File.exists?('spec/javascripts/helpers/.gitkeep').should == true
          File.exists?('spec/javascripts/support/jasmine.yml').should == true
        end
      end

      context 'and the jasmine examples have been installed' do
        it 'should find the Jasmine example files' do
          Bundler.with_clean_env do
            output = `bundle exec rails g jasmine:examples`
            output.should include('create')

            File.exists?('app/assets/javascripts/jasmine_examples/Player.js').should == true
            File.exists?('app/assets/javascripts/jasmine_examples/Song.js').should == true

            File.exists?('spec/javascripts/jasmine_examples/PlayerSpec.js').should == true
            File.exists?('spec/javascripts/helpers/SpecHelper.js').should == true

            output = `bundle exec rake jasmine:ci`
            output.should include('5 specs, 0 failures')
          end
        end
      end
    end
  end
end
