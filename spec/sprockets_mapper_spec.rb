require 'spec_helper'

describe Jasmine::SprocketsMapper do
  describe "mapping files" do
    it "should retrieve asset paths from the the sprockets environment for passed files" do
      src_files = ["assets/application.js", "assets/other_manifest.js"]
      asset1 = double("asset1", :logical_path => "asset1.js")
      asset2 = double("asset2", :logical_path => "asset2.js")
      asset3 = double("asset3", :logical_path => "asset3.js")
      asset_context = double("Sprockets::Environment")
      asset_context.stub_chain(:find_asset).with("application").and_return([asset1, asset2])
      asset_context.stub_chain(:find_asset).with("other_manifest").and_return([asset1, asset3])
      mapper = Jasmine::SprocketsMapper.new(asset_context, 'some_location')
      mapper.files(src_files).should == ['some_location/asset1.js?body=true', 'some_location/asset2.js?body=true', 'some_location/asset3.js?body=true']
    end
  end
end
