module GemInstaller
  class GemCommandProxy
    def gem_cache=(gem_cache)
      @gem_cache = gem_cache
    end

    def gem_runner=(gem_runner)
      @gem_runner = gem_runner
    end

    def is_gem_installed(gem)
      gem_cache = Gem::cache
      gems = gem_cache.refresh!
      gems = gem_cache.search(/.*#{gem.name}$/)
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
      gem_runner = Gem::GemRunner.new
      gem_runner.run(run_args)
    end
  end
end





