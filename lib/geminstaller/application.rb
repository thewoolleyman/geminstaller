require 'yaml'

module GemInstaller
  class Application
    attr_writer :config_builder, :gem_command_manager

    def run
      config = @config_builder.build_config
      gems = config.gems
      gems.each do |gem|
        gem_is_installed = @gem_command_manager.is_gem_installed(gem)
        unless gem_is_installed
          @gem_command_manager.install_gem(gem)
        end
      end
      return 0
    end
  end
end