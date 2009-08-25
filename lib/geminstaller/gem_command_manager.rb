module GemInstaller
  class GemCommandManager
    attr_writer :gem_spec_manager, :gem_runner_proxy
    attr_writer :gem_interaction_handler if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
    
    def list_remote_gem(gem, additional_options)
      run_args = ["list",gem.name,"--remote","--details"]
      run_args << "--all" if GemInstaller::RubyGemsVersionChecker.matches?('>1.0.1')
      run_args += additional_options
      @gem_runner_proxy.run(run_args)
    end

    def uninstall_gem(gem)
      return if !@gem_spec_manager.is_gem_installed?(gem)
      init_gem_interaction_handler(gem)
      run_gem_command('uninstall', gem, gem.uninstall_options)
    end

    def install_gem(gem, force_reinstall = false)
      return [] if @gem_spec_manager.is_gem_installed?(gem) && !force_reinstall
      init_gem_interaction_handler(gem)
      run_gem_command('install', gem, gem.install_options)
    end
    
    def init_gem_interaction_handler(gem)
      @gem_interaction_handler.dependent_gem = gem if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
    end
    
    def dependency(name, version, additional_options = [])
      # rubygems has bug up to 0.9.4 where the pipe options uses 'puts', instead of 'say', so we can't capture it
      # with enhanced_stream_ui.  Patched: http://rubyforge.org/tracker/index.php?func=detail&aid=9020&group_id=126&atid=577
      # TODO: use pipe option on later versions which support it
      
      name_regexp = "^#{name}$"
      name_regexp = "/#{name_regexp}/" if GemInstaller::RubyGemsVersionChecker.matches?('>=1.2.0')
      run_args = ["dependency", name_regexp, "--version", version]
      run_args += additional_options
      output_lines = @gem_runner_proxy.run(run_args)
      # drop the first line which just echoes the dependent gem
      output_lines.shift
      # drop the line containing 'requires' (rubygems < 0.9.0)
      if output_lines[0] == '  Requires'
        output_lines.shift
      end
      # drop all empty lines
      output_lines.reject! { |line| line == "" }
      # strip leading space
      output_lines.each { |line| line.strip! }
      # convert into gems
      output_gems = output_lines.collect do |line|
        name = line.split(' ')[0]
        version_spec = line.split(/[(,)]/)[1]
        GemInstaller::RubyGem.new(name, :version => version_spec)
      end
    end

    def run_gem_command(gem_command, gem, options)
      run_args = [gem_command,gem.name,"--version", "#{gem.version}"]
      if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
        run_args += ['--platform', "#{gem.platform}"] if gem.platform && !gem.platform.empty?
      end
      run_args += options
      @gem_runner_proxy.run(run_args)
    end
  end
end





