require 'spec_helper'

#rspec 1 fails to stub respond_to
if Jasmine::Dependencies.rspec2?
  describe Jasmine::Dependencies do

    context "with ruby gems > 1.8" do
      before do
        Gem::Specification.should_receive(:respond_to?).with(:find_by_name).and_return(true)
      end

      context "and rspec 2" do
        before do
          Gem::Specification.should_receive(:find_by_name).with("rspec", ">= 2.0").and_raise(Gem::LoadError)
        end
        it "should return the correct results" do
          Jasmine::Dependencies.rspec2?.should be false
        end

        it "should not raise an error" do
          lambda do
            Jasmine::Dependencies.rspec2?
          end.should_not raise_error(Gem::LoadError)
        end
      end

      context "and rails 2" do
        before do
          Gem::Specification.should_receive(:find_by_name).with("rails", "~> 2.3").and_raise(Gem::LoadError)
        end
        it "should return the correct results" do
          Jasmine::Dependencies.rails2?.should be false
        end

        it "should not raise an error" do
          lambda do
            Jasmine::Dependencies.rails2?
          end.should_not raise_error(Gem::LoadError)
        end
      end

      context "and rails 3" do
        before do
          Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_raise(Gem::LoadError)
        end
        it "should return the correct results" do
          Jasmine::Dependencies.rails3?.should be false
        end

        it "should not raise an error" do
          lambda do
            Jasmine::Dependencies.rails3?
          end.should_not raise_error(Gem::LoadError)
        end
      end
    end

    context "with ruby_gems < 1.8" do
      before do
        Gem::Specification.should_receive(:respond_to?).with(:find_by_name).and_return(false)
      end
      context "and rspec 2" do
        it "should not break when it is not present" do
          Gem.should_receive(:available?).with("rspec", ">= 2.0").and_return false
          Jasmine::Dependencies.rspec2?.should be false
        end
      end

      context "and rails 2" do
        it "should not break when it is not present" do
          Gem.should_receive(:available?).with("rails", "~> 2.3").and_return false
          Jasmine::Dependencies.rails2?.should be false
        end
      end

      context "and rails 3" do
        it "should not break when it is not present" do
          Gem.should_receive(:available?).with("rails", ">= 3.0").and_return false
          Jasmine::Dependencies.rails3?.should be false
        end
      end
    end

  end

end
