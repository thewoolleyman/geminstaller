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
      gems.each do |gem|
        @gem_command_proxy.install_gem(gem)
      end
      @config
    end
  end
end