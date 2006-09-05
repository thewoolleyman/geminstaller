require 'yaml'

module GemInstaller
  class Application
    def config=(config)
      @config = config
    end
    def run
      config = @config
      config
    end
  end
end