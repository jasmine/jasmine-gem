module Jasmine
  module Dependencies

    class << self
      def rails4?
        rails? && Rails.version.to_i == 4
      end

      def rails5?
        rails? && Rails.version.to_i == 5
      end

      def rails6?
        rails? && Rails.version.to_i == 6
      end

      def rails?
        defined?(Rails) && Rails.respond_to?(:version)
      end

      def use_asset_pipeline?
        (rails4? || rails5? || rails6?) &&
          Rails.respond_to?(:application) &&
          Rails.application.respond_to?(:assets) &&
          !Rails.application.assets.nil?
      end
    end
  end
end
