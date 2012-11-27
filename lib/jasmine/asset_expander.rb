module Jasmine
  class AssetExpander
    def initialize(bundled_asset_factory, asset_path_for)
      @bundled_asset_factory = bundled_asset_factory
      @asset_path_for = asset_path_for
    end

    def expand(src_dir, src_path)
      pathname = src_path.gsub(/^\/?assets\//, '').gsub(/\.js$/, '')
      bundled_asset = @bundled_asset_factory.call(pathname, 'js')
      return nil unless bundled_asset

      base_asset = "#{bundled_asset.pathname.to_s.gsub(/#{src_dir}/, '')}?body=true"
      bundled_asset.to_a.inject([base_asset]) do |assets, asset|
        assets << "/#{@asset_path_for.call(asset).gsub(/^\//, '')}?body=true"
      end.flatten
    end
  end
end
