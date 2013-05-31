module Jasmine

  class AssetBundle
    def self.factory
      if Jasmine::Dependencies.rails3?
        return Rails3AssetBundle
      end
    end

    class Rails3AssetBundle

      def initialize(pathname)
        @pathname = pathname
      end

      def assets
        context = get_asset_context
        context.asset_paths.asset_for(pathname, 'js').to_a.map do |path|
          context.asset_path(path)
        end
      end

      private

      attr_reader :pathname

      def get_asset_context
        context = ::Rails.application.assets.context_class
        context.extend(::Sprockets::Helpers::IsolatedHelper)
        context.extend(::Sprockets::Helpers::RailsHelper)
      end

    end
  end

end
