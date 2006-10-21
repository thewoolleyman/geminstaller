module GemInstaller
  class GemCommandManager
    attr_writer :gem_source_index_proxy
    attr_writer :gem_runner_proxy

    def is_gem_installed(gem)
      @gem_source_index_proxy.refresh!
      gems = @gem_source_index_proxy.search(/#{gem.name}$/,gem.version)
      gems.each do |gem|
        return true if gem.name == gem.name
      end
      return false
    end

    def uninstall_gem(gem)
      return if !is_gem_installed(gem)
      run_gem_command('uninstall',gem)
    end

    def install_gem(gem)
      return if is_gem_installed(gem)
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





