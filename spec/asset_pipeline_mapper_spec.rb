require 'spec_helper'

describe Jasmine::AssetPipelineMapper do
  describe "mapping files" do
    it "should retrieve asset paths from the asset pipeline for passed files" do
      #TODO: this expects all src files to be asset pipeline files
      src_files = ["assets/application.js", "assets/other_manifest.js"]
      asset_context = double("asset context")
      asset_context.stub_chain(:asset_paths, :asset_for).with("application", "js").and_return(['asset1.js', 'asset2.js'])
      asset_context.stub_chain(:asset_paths, :asset_for).with("other_manifest", "js").and_return(['asset1.js', 'asset3.js'])
      asset_context.stub(:asset_path) do |asset|
        "/some_location/#{asset}"
      end
      mapper = Jasmine::AssetPipelineMapper.new(src_files, asset_context)
      mapper.files.should == ['some_location/asset1.js?body=true', 'some_location/asset2.js?body=true', 'some_location/asset3.js?body=true']
    end
  end
end
