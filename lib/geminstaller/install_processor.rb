module GemInstaller
  class InstallProcessor
    attr_writer :gem_list_checker, :gem_command_manager, :missing_dependency_finder, :options, :output_proxy
    def process(gems)
      gems.each do |gem|
        install_gem(gem)
      end
    end
    
    def install_gem(gem)
      already_specified = false
      if gem.check_for_upgrade
        @gem_list_checker.verify_and_specify_remote_gem!(gem)
        already_specified = true
      end
      gem_is_installed = @gem_command_manager.is_gem_installed?(gem)
      if gem_is_installed 
        @output_proxy.sysout("Gem #{gem.name}, version #{gem.version} is already installed.\n") if @options[:info]
        if gem.fix_dependencies
          fix_dependencies(gem)
        end
      else
        @gem_list_checker.verify_and_specify_remote_gem!(gem) unless already_specified
        @output_proxy.sysout("Installing gem #{gem.name}, version #{gem.version}.\n") if @options[:info]
        @gem_command_manager.install_gem(gem)
      end
    end

    def fix_dependencies(gem)
      missing_dependencies = @missing_dependency_finder.find(gem)
      if missing_dependencies.size > 0
        missing_dependencies.each do |missing_dependency|
          @output_proxy.sysout("Installing #{missing_dependency.name} (#{missing_dependency.version})\n")
        end
      end
    end
    
  end
end