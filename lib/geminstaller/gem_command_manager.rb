module GemInstaller
  class GemCommandManager
    def gem_source_index_proxy=(gem_source_index_proxy)
      @gem_source_index_proxy = gem_source_index_proxy
    end

    def gem_runner_proxy=(gem_runner_proxy)
      @gem_runner_proxy = gem_runner_proxy
    end

    def is_gem_installed(gem)
      @gem_source_index_proxy.refresh!
      gems = @gem_source_index_proxy.search(/#{gem.name}$/)
      # TODO: add version to install check
      gems.each do |gem|
        return true if gem.name == gem.name
      end
      return false
    end

    def uninstall_gem(gem)
      run_gem_command('uninstall',gem)
    end

    def install_gem(gem)
      run_gem_command('install',gem)
    end

    private
    def run_gem_command(gem_command,gem)
      run_args = [gem_command,gem.name,"--version", "#{gem.version}"]
      run_args += gem.install_options
      @gem_runner_proxy.run(run_args)
    end
  end
end





