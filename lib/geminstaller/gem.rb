require 'yaml'

module GemInstaller
  class Gem
    def initialize(name, version)
      @name = name
      @version = version
    end

    def name
      @name
    end

    def version
      @version
    end
  end
end