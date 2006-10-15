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
        gem_is_installed = @gem_command_proxy.is_gem_installed(gem)
        unless gem_is_installed
          @gem_command_proxy.install_gem(gem)
        end
      end
      @config
    end
  end
end