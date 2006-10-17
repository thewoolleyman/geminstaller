require 'yaml'

module GemInstaller
  class Application
    def config=(config)
      @config = config
    end
    def gem_command_manager=(gem_command_manager)
      @gem_command_manager = gem_command_manager
    end
    def run
      gem_command_manager = @gem_command_manager
      gems = @config.gems
      gems.each do |gem|
        gem_is_installed = @gem_command_manager.is_gem_installed(gem)
        unless gem_is_installed
          @gem_command_manager.install_gem(gem)
        end
      end
      @config
    end
  end
end