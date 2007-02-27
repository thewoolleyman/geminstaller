module GemInstaller
  class GemCommandManager
    attr_writer :gem_source_index_proxy
    attr_writer :gem_runner_proxy
    attr_writer :noninteractive_chooser
    
    def list_remote_gem(gem, list_options)
      run_args = ["list",gem.name,"--remote"]
      run_args += list_options
      @gem_runner_proxy.run(run_args)
    end

    def is_gem_installed(gem)
      @gem_source_index_proxy.refresh!
      gem_name_regexp = /^#{gem.regexp_escaped_name}$/
      found_gems = @gem_source_index_proxy.search(gem_name_regexp,gem.version)
      found_gems.each do |found_gem|
        platform_matches = true if
          (gem.platform == Gem::Platform::CURRENT && found_gem.platform = RUBY_PLATFORM) or
          found_gem.platform == gem.platform
        return true if found_gem.name == gem.name && platform_matches
      end
      return false
    end

    def uninstall_gem(gem)
      return if !is_gem_installed(gem)
      setup_noninteractive_chooser(:uninstall_list_type, gem)
      run_gem_command('uninstall',gem)
    end

    def install_gem(gem)
      return if is_gem_installed(gem)
      setup_noninteractive_chooser(:install_list_type, gem)
      run_gem_command('install',gem)
    end

    def setup_noninteractive_chooser(list_type, gem)
      @noninteractive_chooser.specify_exact_gem_spec(gem.name, gem.version, gem.platform)
    end
    
    def run_gem_command(gem_command,gem)
      run_args = [gem_command,gem.name,"--version", "#{gem.version}"]
      run_args += gem.install_options
      @gem_runner_proxy.run(run_args)
    end
  end
end





