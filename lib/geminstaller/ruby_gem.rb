require 'yaml'

module GemInstaller
  class RubyGem
    def initialize(name, version, install_options = [])
      @name = name
      @version = version
      @install_options = install_options
    end

    def name
      @name
    end

    def version
      @version ||= default_version
    end

    def install_options
      @install_options
    end

    def default_version
      '> 0.0.0'
    end

  end
end