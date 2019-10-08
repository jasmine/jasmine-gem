module Jasmine
  class AssetExpander
    def expand(src_dir, src_path)
      pathname = src_path.gsub(/^\/?assets\//, '')

      asset_bundle.assets(pathname).flat_map { |asset|
        "/#{asset.gsub(/^\//, '')}"
      }
    end

    private

    UnsupportedRailsVersion = Class.new(StandardError)

    def asset_bundle
      return Rails4Or5Or6AssetBundle.new if Jasmine::Dependencies.rails4? || Jasmine::Dependencies.rails5? || Jasmine::Dependencies.rails6?
      raise UnsupportedRailsVersion, "Jasmine only supports the asset pipeline for Rails 4. - 6"
    end

    class Rails4Or5Or6AssetBundle
      def assets(pathname)
        if pathname =~ /\.css$/
          context.get_stylesheet_assets(pathname.gsub(/\.css$/, ''))
        else
          context.get_javascript_assets(pathname.gsub(/\.js$/, ''))
        end
      end

      private

      def context
        @context ||= ActionView::Base.new.extend(GetOriginalAssetsHelper)
      end

      module GetOriginalAssetsHelper
        def get_javascript_assets(pathname)
          if asset = lookup_debug_asset(pathname, type: :javascript)
            if asset.respond_to?(:to_a)
              asset.to_a.map do |a|
                path_to_javascript(a.logical_path, debug: true)
              end
            else
              Array(path_to_javascript(asset.logical_path, debug: true))
            end
          else
            []
          end
        end

        def get_stylesheet_assets(pathname)
          if asset = lookup_debug_asset(pathname, type: :stylesheet)
            if asset.respond_to?(:to_a)
              asset.to_a.map do |a|
                path_to_stylesheet(a.logical_path, debug: true)
              end
            else
              Array(path_to_stylesheet(asset.logical_path, debug: true))
            end
          else
            []
          end
        end
      end
    end
  end
end
