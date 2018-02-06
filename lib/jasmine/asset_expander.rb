module Jasmine
  class AssetExpander
    def expand(src_dir, src_path)
      pathname = src_path.gsub(/^\/?assets\//, '').gsub(/\.js$/, '')

      asset_bundle.assets(pathname).flat_map { |asset|
        "/#{asset.gsub(/^\//, '')}?body=true"
      }
    end

    private

    UnsupportedRailsVersion = Class.new(StandardError)

    def asset_bundle
      return Rails4Or5AssetBundle.new if Jasmine::Dependencies.rails4? || Jasmine::Dependencies.rails5?
      raise UnsupportedRailsVersion, "Jasmine only supports the asset pipeline for Rails 4 - 5"
    end

    class Rails4Or5AssetBundle
      def assets(pathname)
        context.get_original_assets(pathname)
      end

      private

      def context
        @context ||= ActionView::Base.new.extend(GetOriginalAssetsHelper)
      end

      module GetOriginalAssetsHelper
        def get_original_assets(pathname)
          Array(assets_environment.find_asset(pathname)).map do |processed_asset|
            case processed_asset.content_type
            when "text/css"
              path_to_stylesheet(processed_asset.logical_path, debug: true)
            when "application/javascript"
              path_to_javascript(processed_asset.logical_path, debug: true)
            end
          end
        end
      end
    end
  end
end
