require 'yaml'

module GemInstaller
  class Gem
    def initialize(name, version, install_options)
      @name = name
      @version = version
      @install_options = install_options
    end

    def name
      @name
    end

    def version
      @version
    end

    def install_options
      @install_options
    end
  end
end