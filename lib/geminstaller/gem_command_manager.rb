module GemInstaller
  class NoninteractiveChooserFactory
    def create
      GemInstaller::NoninteractiveChooser.new
    end
  end
  
  class GemCommandManager
    attr_writer :gem_source_index_proxy
    attr_writer :gem_runner_proxy
    attr_writer :noninteractive_chooser
    
    def is_gem_installed(gem)
      @gem_source_index_proxy.refresh!
      gem_name_regexp = /^#{Regexp.escape(gem.name)}$/
      found_gems = @gem_source_index_proxy.search(gem_name_regexp,gem.version)
      found_gems.each do |found_gem|
        return true if found_gem.name == gem.name && found_gem.platform = gem.platform
      end
      return false
    end

    def uninstall_gem(gem)
      return if !is_gem_installed(gem)
      setup_noninteractive_chooser(gem)
      run_gem_command('uninstall',gem)
    end

    def install_gem(gem)
      return if is_gem_installed(gem)
      setup_noninteractive_chooser(gem)
      run_gem_command('install',gem)
    end

    private
    def setup_noninteractive_chooser(gem)
      @noninteractive_chooser ||= NoninteractiveChooser.new
      @noninteractive_chooser.gem_source_index_proxy = @gem_source_index_proxy
      @noninteractive_chooser.specify_exact_gem_spec(gem.name, gem.version, gem.platform)
      Gem::StreamUI.noninteractive_chooser = @noninteractive_chooser
    end
    
    def run_gem_command(gem_command,gem)
      run_args = [gem_command,gem.name,"--version", "#{gem.version}"]
      run_args += gem.install_options
      @gem_runner_proxy.run(run_args)
    end
  end
end





