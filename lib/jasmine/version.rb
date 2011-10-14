module Jasmine
  VERSION = "1.1.1"

  RUBYGEMS_VERSION = Gem::Version.create(Gem::VERSION) >= Gem::Version.create("1.8") ? "pos18" : "pre18"
end
