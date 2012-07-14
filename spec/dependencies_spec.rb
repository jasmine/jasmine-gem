require 'spec_helper'

#rspec 1 fails to stub respond_to
if Jasmine::Dependencies.rspec2?
  describe Jasmine::Dependencies do
    module Rails
    end

    context "with ruby_gems > 1.8" do
      before do
        Gem::Specification.should_receive(:respond_to?).with(:find_by_name).and_return(true)
      end

      describe ".rspec2?" do
        subject { Jasmine::Dependencies.rspec2? }
        context "when rspec 2 is present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rspec", ">= 2.0").and_return(true)
          end
          it { should be_true }
        end
        context "when rspec 2 is not present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rspec", ">= 2.0").and_raise(Gem::LoadError)
          end
          it { should be_false }
        end
      end

      describe ".rails2?" do
        subject { Jasmine::Dependencies.rails2? }
        context "when rails 2 is present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", "~> 2.3").and_return(true)
          end
          it { should be_true }
        end
        context "when rails 2 is not present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", "~> 2.3").and_raise(Gem::LoadError)
          end
          it { should be_false }
        end
      end

      describe ".legacy_rails?" do
        subject { Jasmine::Dependencies.legacy_rails? }
        context "when rails < 2.3.11 is present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", "< 2.3.11").and_return(true)
          end
          it { should be_true }
        end
        context "when rails < 2.3.11 is not present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", "< 2.3.11").and_raise(Gem::LoadError)
          end
          it { should be_false }
        end
      end

      describe ".rails3?" do
        subject { Jasmine::Dependencies.rails3? }
        context "when rails 3 is present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_return(true)
          end
          it { should be_true }
        end
        context "when rails 3 is not present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_raise(Gem::LoadError)
          end
          it { should be_false }
        end
      end

      describe ".rails_3_asset_pipeline?" do
        subject { Jasmine::Dependencies.rails_3_asset_pipeline? }
        let(:application) { double(:application) }
        before do
          Rails.stub(:respond_to?).with(:application).and_return(respond_to_application)
          Rails.stub(:application).and_return(application)
        end
        context "when rails 3 is present and the application pipeline is in use" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_return(true)
            application.stub(:assets).and_return(rails_application_assets)
          end
          let(:rails3_present) { true }
          let(:respond_to_application) { true }
          let(:rails_application_assets) { true }
          it { should be_true }
        end
        context "when rails 3 is present and the application pipeline is not in use" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_return(true)
            application.stub(:assets).and_return(rails_application_assets)
          end
          let(:rails3_present) { true }
          let(:respond_to_application) { true }
          let(:rails_application_assets) { false }
          it { should be_false }
        end
        context "when rails 3 is present but not loaded" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_return(true)
            application.stub(:assets).and_return(rails_application_assets)
          end
          let(:rails3_present) { true }
          let(:respond_to_application) { false }
          let(:rails_application_assets) { false }
          it { should be_false }
        end
        context "when rails 3 is present but doesn't respond to assets" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_return(true)
          end
          let(:rails3_present) { true }
          let(:respond_to_application) { true }
          it { should be_false }
        end
        context "when rails 3 is not present" do
          before do
            Gem::Specification.should_receive(:find_by_name).with("rails", ">= 3.0").and_raise(Gem::LoadError)
          end
          let(:rails3_present) { false }
          let(:respond_to_application) { false }
          let(:rails_application_assets) { false }
          it { should be_false }
        end
      end
    end

    context "with ruby_gems < 1.8" do
      before do
        Gem::Specification.should_receive(:respond_to?).with(:find_by_name).and_return(false)
      end

      describe ".rspec2?" do
        subject { Jasmine::Dependencies.rspec2? }
        before do
          Gem.should_receive(:available?).with("rspec", ">= 2.0").and_return(rspec2_present)
        end
        context "when rspec 2 is present" do
          let(:rspec2_present) { true }
          it { should be_true }
        end
        context "when rspec 2 is not present" do
          let(:rspec2_present) { false }
          it { should be_false }
        end
      end

      describe ".rails2?" do
        subject { Jasmine::Dependencies.rails2? }
        before do
          Gem.should_receive(:available?).with("rails", "~> 2.3").and_return(rails2_present)
        end
        context "when rails 2 is present" do
          let(:rails2_present) { true }
          it { should be_true }
        end
        context "when rails 2 is not present" do
          let(:rails2_present) { false }
          it { should be_false }
        end
      end

      describe ".legacy_rails?" do
        subject { Jasmine::Dependencies.legacy_rails? }
        before do
          Gem.should_receive(:available?).with("rails", "< 2.3.11").and_return(legacy_rails_present)
        end
        context "when rails < 2.3.11 is present" do
          let(:legacy_rails_present) { true }
          it { should be_true }
        end
        context "when rails < 2.3.11 is not present" do
          let(:legacy_rails_present) { false }
          it { should be_false }
        end
      end

      describe ".rails3?" do
        subject { Jasmine::Dependencies.rails3? }
        before do
          Gem.should_receive(:available?).with("rails", ">= 3.0").and_return(rails3_present)
        end
        context "when rails 3 is present" do
          let(:rails3_present) { true }
          it { should be_true }
        end
        context "when rails 3 is not present" do
          let(:rails3_present) { false }
          it { should be_false }
        end
      end

      describe ".rails_3_asset_pipeline?" do
        subject { Jasmine::Dependencies.rails_3_asset_pipeline? }
        let(:application) { double(:application, :assets => rails_application_assets)}
        before do
          Gem.should_receive(:available?).with("rails", ">= 3.0").and_return(rails3_present)
          Rails.stub(:respond_to?).with(:application).and_return(respond_to_application)
          Rails.stub(:application).and_return(application)
        end
        context "when rails 3 is present and the application pipeline is in use" do
          let(:rails3_present) { true }
          let(:respond_to_application) { true }
          let(:rails_application_assets) { true }
          it { should be_true }
        end
        context "when rails 3 is present and the application pipeline is not in use" do
          let(:rails3_present) { true }
          let(:respond_to_application) { true }
          let(:rails_application_assets) { false }
          it { should be_false }
        end
        context "when rails 3 is present but not loaded" do
          let(:rails3_present) { true }
          let(:respond_to_application) { false }
          let(:rails_application_assets) { false }
          it { should be_false }
        end
        context "when rails 3 is not present" do
          let(:rails3_present) { false }
          let(:respond_to_application) { false }
          let(:rails_application_assets) { false }
          it { should be_false }
        end
      end
    end

    describe "legacy_rack?" do
      it "should return false if Rack::Server exists" do
        Rack.stub(:constants).and_return([:Server])
        Jasmine::Dependencies.legacy_rack?.should be_false
      end
      it "should return true if Rack::Server does not exist" do
        Rack.stub(:constants).and_return([])
        Jasmine::Dependencies.legacy_rack?.should be_true
      end
    end
  end

end
