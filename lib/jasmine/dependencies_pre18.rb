module Jasmine
  module Dependencies

    def self.rspec2?
      Gem.available? "rspec", ">= 2.0"
    end

    def self.rails2?
      Gem.available? "rails", "~> 2.3"
    end

    def self.rails3?
      Gem.available? "rails", ">= 3.0"
    end
  end
end
