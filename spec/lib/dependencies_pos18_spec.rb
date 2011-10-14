if Jasmine::RUBYGEMS_VERSION == "pos18"
  require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "jasmine", "dependencies_pos18"))

  describe Jasmine do

    describe "Gem version indentification" do
      context "of rspec 2" do
        it "should not break when it is not present" do
          Gem::Specification.should_receive(:find_by_name).with("rspec", ">= 2.0").twice().and_raise(Gem::LoadError)
          Jasmine::Dependencies.rspec2?.should be false
          Jasmine::Dependencies.rspec2?.should_not raise_error(Gem::LoadError)
        end
      end

      context "of rails 2" do
        it "should not break when it is not present" do
          Gem::Specification.should_receive(:find_by_name).with("rails", "~> 2.3").twice().and_raise(Gem::LoadError)
          Jasmine::Dependencies.rails2?.should be false
          Jasmine::Dependencies.rails2?.should_not raise_error(Gem::LoadError)
        end
      end

      context "of rails 3"
      it "should not break when it is not present" do
        Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").twice().and_raise(Gem::LoadError)
        Jasmine::Dependencies.rails3?.should be false
        Jasmine::Dependencies.rails3?.should_not raise_error(Gem::LoadError)
      end
    end
  end
end
