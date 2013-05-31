module Jasmine
  class AssetExpander
    def initialize(bundled_asset_factory)
      @bundled_asset_factory = bundled_asset_factory
    end

    def expand(src_dir, src_path)
      pathname = src_path.gsub(/^\/?assets\//, '').gsub(/\.js$/, '')
      bundled_asset = bundled_asset_factory.new(pathname)
      bundled_asset.assets.map do |asset|
        "/#{asset.gsub(/^\//, '')}?body=true"
      end.flatten
    end

    private
    attr_reader :bundled_asset_factory
  end
end
