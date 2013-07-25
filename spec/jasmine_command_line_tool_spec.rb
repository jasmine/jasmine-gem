require 'spec_helper'

describe 'Jasmine command line tool' do
  before :each do
    temp_dir_before
    Dir::chdir @tmp
  end

  after :each do
    temp_dir_after
  end

  describe '.init' do
      it 'should create files on init' do
        output = capture_stdout { Jasmine::CommandLineTool.new.process ['init'] }
        output.should =~ /Jasmine has been installed with example specs./

        my_jasmine_lib = File.expand_path(File.join(@root, 'lib'))
        bootstrap = "$:.unshift('#{my_jasmine_lib}')"

        ENV['JASMINE_GEM_PATH'] = "#{@root}/lib"
        ci_output = `rake -E "#{bootstrap}" --trace jasmine:ci`
        ci_output.should =~ (/[1-9][0-9]* specs, 0 failures/)
      end

      describe 'with a Gemfile containing Rails' do
          before :each do
              open(File.join(@tmp, "Gemfile"), 'w') do |f|
                  f.puts "rails"
              end
          end

          it 'should warn the user' do
            output = capture_stdout { 
                expect {
                    Jasmine::CommandLineTool.new.process ['init']
                }.to raise_error SystemExit
            }
            output.should =~ /attempting to run jasmine init in a Rails project/

            Dir.entries(@tmp).sort.should == [".", "..", "Gemfile"]
          end
          
          it 'should allow the user to override the warning' do
            output = capture_stdout { 
                expect {
                    Jasmine::CommandLineTool.new.process ['init', '--force']
                }.not_to raise_error
            }
            output.should =~ /Jasmine has been installed with example specs./

            Dir.entries(@tmp).sort.should == [".", "..", "Gemfile", "Rakefile", "public", "spec"]
          end
      end
      
      describe 'with a Gemfile not containing Rails' do
          before :each do
              open(File.join(@tmp, "Gemfile"), 'w') do |f|
                  f.puts "sqlite3"
              end
          end

          it 'should perform normally' do
            output = capture_stdout { 
                expect {
                    Jasmine::CommandLineTool.new.process ['init']
                }.not_to raise_error
            }
            output.should =~ /Jasmine has been installed with example specs./

            Dir.entries(@tmp).sort.should == [".", "..", "Gemfile", "Rakefile", "public", "spec"]
          end
      end
  end


  it 'should include license info' do
    output = capture_stdout { Jasmine::CommandLineTool.new.process ['license'] }
    output.should =~ /Copyright/
  end
end
