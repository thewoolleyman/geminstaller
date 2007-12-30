module GemInstaller
  class GemCommandManager
    attr_writer :gem_spec_manager, :gem_runner_proxy, :gem_interaction_handler
    
    def list_remote_gem(gem, additional_options)
      run_args = ["list",gem.name,"--remote","--details"]
      run_args += additional_options
      @gem_runner_proxy.run(run_args)
    end

    def uninstall_gem(gem)
      return if !@gem_spec_manager.is_gem_installed?(gem)
      @gem_interaction_handler.dependent_gem = gem
      run_gem_command('uninstall', gem, gem.uninstall_options)
    end

    def install_gem(gem)
      return [] if @gem_spec_manager.is_gem_installed?(gem)
      @gem_interaction_handler.dependent_gem = gem
      run_gem_command('install', gem, gem.install_options)
    end
    
    def dependency(name, version, additional_options = [])
      # rubygems has bug up to 0.9.4 where the pipe options uses 'puts', instead of 'say', so we can't capture it
      # with enhanced_stream_ui.  Patched: http://rubyforge.org/tracker/index.php?func=detail&aid=9020&group_id=126&atid=577
      # TODO: use pipe option on later versions which support it
      
      run_args = ["dependency","^#{name}$","--version",version]
      run_args += additional_options
      output_lines = @gem_runner_proxy.run(run_args)
      # dependency output has all lines in the first element
      output_array = output_lines[0].split("\n")
      # drop the first line which just echoes the dependent gem
      output_array.shift
      # drop the line containing 'requires' (rubygems < 0.9.0)
      if output_array[0] == '  Requires'
        output_array.shift
      end
      # drop all empty lines
      output_array.reject! { |line| line == "" }
      # strip leading space
      output_array.each { |line| line.strip! }
      # convert into gems
      output_gems = output_array.collect do |line|
        name = line.split(' ')[0]
        version_spec = line.split(/[()]/)[1]
        GemInstaller::RubyGem.new(name, :version => version_spec)
      end
    end

    def run_gem_command(gem_command, gem, options)
      run_args = [gem_command,gem.name,"--version", "#{gem.version}"]
      if RUBYGEMS_VERSION_CHECKER.matches?('>=0.9.5')
        run_args += ['--platform', "#{gem.platform}"]
      end
      run_args += options
      @gem_runner_proxy.run(run_args)
    end
  end
end





