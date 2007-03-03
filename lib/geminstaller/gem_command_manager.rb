module GemInstaller
  class GemCommandManager
    attr_writer :gem_source_index_proxy, :gem_runner_proxy, :gem_interaction_handler
    
    def list_remote_gem(gem, list_options)
      run_args = ["list",gem.name,"--remote"]
      run_args += list_options
      @gem_runner_proxy.run(run_args)
    end

    def is_gem_installed?(gem)
      return local_matching_gem_specs(gem).size > 0
    end
    
    def local_matching_gem_specs(gem)
      @gem_source_index_proxy.refresh!
      gem_name_regexp = /^#{gem.regexp_escaped_name}$/
      found_gem_specs = @gem_source_index_proxy.search(gem_name_regexp,gem.version)
      return [] unless found_gem_specs
      matching_gem_specs = found_gem_specs.select do |gem_spec|
        gem_matches_spec?(gem, gem_spec)
      end
      return matching_gem_specs
    end
    
    def gem_matches_spec?(gem, gem_spec)
      if (gem.platform == Gem::Platform::CURRENT && gem_spec.platform = RUBY_PLATFORM) or
         gem_spec.platform == gem.platform
         platform_matches = true 
      end
      return gem_spec.name == gem.name && platform_matches
    end

    def uninstall_gem(gem)
      return if !is_gem_installed?(gem)
      @gem_interaction_handler.parent_gem = gem
      run_gem_command('uninstall',gem)
    end

    def install_gem(gem)
      return if is_gem_installed?(gem)
      @gem_interaction_handler.parent_gem = gem
      run_gem_command('install',gem)
    end

    def run_gem_command(gem_command,gem)
      run_args = [gem_command,gem.name,"--version", "#{gem.version}"]
      run_args += gem.install_options
      @gem_runner_proxy.run(run_args)
    end
  end
end





