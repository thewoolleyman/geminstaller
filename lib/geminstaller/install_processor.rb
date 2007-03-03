module GemInstaller
  class InstallProcessor
    attr_writer :gem_list_checker, :gem_command_manager, :options, :output_proxy
    def process(gem)
      already_specified = false
      if gem.check_for_upgrade
        @gem_list_checker.verify_and_specify_remote_gem!(gem)
        already_specified = true
      end
      gem_is_installed = @gem_command_manager.is_gem_installed(gem)
      if gem_is_installed 
        @output_proxy.sysout("Gem #{gem.name}, version #{gem.version} is already installed.\n") if @options[:info]
      else
        @gem_list_checker.verify_and_specify_remote_gem!(gem) unless already_specified
        @output_proxy.sysout("Installing gem #{gem.name}, version #{gem.version}.\n") if @options[:info]
        @gem_command_manager.install_gem(gem)
      end
    end
  end
end