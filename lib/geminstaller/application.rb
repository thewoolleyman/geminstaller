require 'yaml'

module GemInstaller
  class Application
    def config=(config)
      @config = config
    end
    def gem_command_proxy=(gem_command_proxy)
      @gem_command_proxy = gem_command_proxy
    end
    def run
      gem_command_proxy = @gem_command_proxy
      gems = @config.gems
      config
    end
  end
end