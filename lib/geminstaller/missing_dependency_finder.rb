module GemInstaller
  class MissingDependencyFinder
    attr_writer :gem_command_manager, :gem_spec_manager, :gem_arg_processor, :output_filter
    def find(dependent_gem)
      # NOTE: this doesn't resolve platforms, there's currently no way to know what
      # platform should be selected for a dependency gem.  Best-effort handling
      # of ambiguous platforms on dependency gems will be handled elsewhere
      matching_dependent_gems = @gem_spec_manager.local_matching_gems(dependent_gem)
      missing_dependencies = []
      install_options = dependent_gem.install_options
      add_include_dependency_option(install_options)
      common_args = @gem_arg_processor.strip_non_common_gem_args(install_options)
      matching_dependent_gems.each do |matching_dependent_gem|
        message_already_printed = false
        dependency_gems = @gem_command_manager.dependency(matching_dependent_gem.name, matching_dependent_gem.version.to_s, common_args)
        dependency_gems.each do |dependency_gem|
          dependency_gem.install_options = install_options
          local_matching_dependency_gems = @gem_spec_manager.local_matching_gems(dependency_gem, false)
          unless local_matching_dependency_gems.size > 0
            unless message_already_printed
              @output_filter.geminstaller_output(:info, "Missing dependencies found for #{matching_dependent_gem.name} (#{matching_dependent_gem.version}):\n")
              message_already_printed = true
            end
            # TODO: print install options too?
            @output_filter.geminstaller_output(:info, "  #{dependency_gem.name} (#{dependency_gem.version})\n")
            missing_dependencies << dependency_gem
          end        
          # recurse to find any missing dependencies in the tree
          sub_dependencies = find(dependency_gem)
          missing_dependencies += sub_dependencies if sub_dependencies.size > 0 
        end
      end
      return missing_dependencies
    end
    
    def add_include_dependency_option(install_options)
      return if install_options.index('-y') or install_options.index('--include-dependencies')
      install_options << '--include-dependencies'
    end
  end
end