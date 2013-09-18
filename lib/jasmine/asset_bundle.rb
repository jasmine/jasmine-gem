module Jasmine

  class AssetBundle
    def self.factory
      if Jasmine::Dependencies.rails3?
        return Rails3AssetBundle
      end
      if Jasmine::Dependencies.rails4?
        return Rails4AssetBundle
      end
    end

    class RailsAssetBundle
      def initialize(pathname)
        @pathname = pathname
      end

      private

      attr_reader :pathname
    end

    class Rails3AssetBundle < RailsAssetBundle

      def assets
        context = get_asset_context
        context.asset_paths.asset_for(pathname, nil).to_a.map do |path|
          context.asset_path(path)
        end
      end

      private
      def get_asset_context
        context = ::Rails.application.assets.context_class
        context.extend(::Sprockets::Helpers::IsolatedHelper)
        context.extend(::Sprockets::Helpers::RailsHelper)
      end
    end

    class Rails4AssetBundle < RailsAssetBundle

      def assets
        context.get_original_assets(pathname)
      end

      private
      def context
        return @context if @context
        @context = ActionView::Base.new
        @context.instance_eval do
          def get_original_assets(pathname)
            assets_environment.find_asset(pathname).to_a.map do |processed_asset|
              case processed_asset.content_type
              when "text/css"
                path_to_stylesheet(processed_asset.logical_path)
              when "application/javascript"
                path_to_javascript(processed_asset.logical_path)
              end
            end
          end
        end
        @context

      end
    end
  end

end
