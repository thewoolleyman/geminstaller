module GemInstaller
  class MissingDependencyFinder
    attr_writer :gem_command_manager, :gem_arg_processor, :output_proxy
    def find(gem)
      # NOTE: this doesn't resolve platforms, there's currently no way to know what
      # platform should be selected for a dependency gem.  Best-effort handling
      # of ambiguous platforms on dependency gems will be handled elsewhere
      matching_gem_specs = @gem_command_manager.local_matching_gem_specs(gem)
      missing_dependencies = []
      install_options = gem.install_options
      add_include_dependency_option(install_options)
      common_args = @gem_arg_processor.strip_non_common_gem_args(gem.install_options)
      matching_gem_specs.each do |matching_gem_spec|
        message_already_printed = false
        dependency_output_lines = @gem_command_manager.dependency(matching_gem_spec.name, matching_gem_spec.version.to_s, common_args)
        dependency_output_lines.each do |dependency_output_line|
          name = dependency_output_line.split(' ')[0]
          version_spec = dependency_output_line.split(/[()]/)[1]
          dependency_gem = GemInstaller::RubyGem.new(name, :version => version_spec, :install_options => install_options)
          local_matching_gem_specs = @gem_command_manager.local_matching_gem_specs(dependency_gem)
          unless local_matching_gem_specs.size > 0
            unless message_already_printed
              @output_proxy.sysout("Missing dependencies found for #{matching_gem_spec.name} (#{matching_gem_spec.version})\n")
              message_already_printed = true
            end
            # TODO: print install options too?
            @output_proxy.sysout("  #{name} (#{version_spec})\n")
            missing_dependencies << dependency_gem
          end        
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