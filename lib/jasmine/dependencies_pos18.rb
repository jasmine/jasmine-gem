module Jasmine
  module Dependencies

    def self.rspec2?
      Gem::Specification::find_by_name "rspec", ">= 2.0"
    rescue Gem::LoadError
      false
    end

    def self.rails2?
      return Rails.version.split(".").first.to_i == 2 if defined? Rails
      begin
        Gem::Specification::find_by_name "rails", "~> 2.3"
      rescue Gem::LoadError
        false
      end
    end

    def self.rails3?
      return Rails.version.split(".").first.to_i == 3 if defined? Rails
      begin
        Gem::Specification::find_by_name "rails", ">= 3.0"
      rescue Gem::LoadError
        false
      end
    end
  end
end
