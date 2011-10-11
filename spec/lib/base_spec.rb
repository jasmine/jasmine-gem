require File.expand_path(File.join(File.dirname(__FILE__), "..","spec_helper"))

describe Jasmine do
  
  describe "Rails version indentification" do
    context "when gem is not available" do
      it "should not break without rspec 2" do
        Jasmine::Dependencies.rspec2?.should_not raise_error(Gem::LoadError)
      end
      
      it "should not break without rails 3" do
        Jasmine::Dependencies.rails3?.should_not raise_error(Gem::LoadError)
      end
    end
  end
end
