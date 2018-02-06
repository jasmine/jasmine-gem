module Jasmine
  module Dependencies

    class << self
      def rails4?
        rails? && Rails.version.to_i == 4
      end

      def rails5?
        rails? && Rails.version.to_i == 5
      end

      def rails?
        defined?(Rails) && Rails.respond_to?(:version)
      end

      def use_asset_pipeline?
        assets_pipeline_available = (rails4? || rails5?) && Rails.respond_to?(:application) && Rails.application.respond_to?(:assets) && !Rails.application.assets.nil?
        assets_pipeline_available && (rails4? || rails5?)
      end
    end
  end
end
