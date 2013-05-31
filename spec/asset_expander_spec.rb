require 'spec_helper'

describe Jasmine::AssetExpander do
  it "expands asset files" do
    bundled_asset = double(:bundled_asset, :assets => ['asset1_path', 'asset2_path'])
    bundled_asset_factory = double(:bundled_asset_factory)
    bundled_asset_factory.should_receive(:new).with('asset_file').and_return(bundled_asset)
    expander = Jasmine::AssetExpander.new(bundled_asset_factory)
    expanded_assets = expander.expand('/some_src_dir', 'asset_file')
    expanded_assets.should == ['/asset1_path?body=true',
                               '/asset2_path?body=true']
  end
end
