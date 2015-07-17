require 'spec_helper'

describe Jasmine do
  it "should provide the root path" do
    File.stub(:dirname).and_return('lib/jasmine')
    File.should_receive(:expand_path) { |path| path }
    Jasmine.root.should == 'lib/jasmine'
  end
  it "should append passed file paths" do
    File.stub(:dirname).and_return('lib/jasmine')
    File.should_receive(:expand_path) { |path| path }
    Jasmine.root('subdir1', 'subdir2').should == File.join('lib/jasmine', 'subdir1', 'subdir2')
  end
  describe '#load_spec' do
    it 'assigns the spec to the spec path' do
      Jasmine.load_spec("spec/test")
      Jasmine.config.spec_files.should == [ "spec/test" ]
    end

    it 'does not assign a spec path if passed a nil' do
      Jasmine.load_spec("spec/test")
      Jasmine.load_spec(nil)
      Jasmine.config.spec_files.should == [ "spec/test" ]
    end

    it 'does not override nonspec files' do
      Jasmine.config.helper_files = ["aaa"]
      Jasmine.load_spec("spec/test")
      Jasmine.config.spec_files.should == [ "spec/test" ]
      Jasmine.config.helper_files.should == ["aaa"]
    end
  end
end
