if Jasmine::RUBYGEMS_VERSION == "pre18"
  require File.expand_path(File.join(File.dirname(__FILE__), "..", "..", "lib", "jasmine", "dependencies_pre18"))

  describe Jasmine do

    describe "Gem version indentification" do
      context "of rspec 2" do
        it "should not break when it is not present" do
          Gem.should_receive(:available?).with("rspec", ">= 2.0").and_return false
          Jasmine::Dependencies.rspec2?.should be false
        end
      end

      context "of rails 2" do
        it "should not break when it is not present" do
          Gem.should_receive(:available?).with("rails", "~> 2.3").and_return false
          Jasmine::Dependencies.rails2?.should be false
        end
      end

      context "of rails 3" do
        it "should not break when it is not present" do
          Gem.should_receive(:available?).with("rails", ">= 3.0").and_return false
          Jasmine::Dependencies.rails3?.should be false
        end
      end
    end
  end
end
