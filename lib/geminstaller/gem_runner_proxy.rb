module GemInstaller
  class GemRunnerProxy
    attr_writer :gem_runner_class, :gem_cmd_manager_class, :output_listener, :exact_match_list_command
    attr_writer :options, :enhanced_stream_ui, :output_filter

    def run(args = [], stdin = [])
      @output_filter.geminstaller_output(:commandecho,"'gem #{args.join(' ')}'\n")
      gem_runner = create_gem_runner
      # We have to manually initialize the configuration here, or else the GemCommandManager singleton
      # will initialize with the (incorrect) default args when we call GemRunner.run.
      gem_runner.do_configuration(args)
      gem_cmd_manager = @gem_cmd_manager_class.instance
      gem_cmd_manager.ui = @enhanced_stream_ui
      gem_cmd_manager.commands[:list] = @exact_match_list_command
      
      exit_status = nil
      begin
        gem_runner.run(args)
      rescue SystemExit => system_exit
        if GemInstaller::RubyGemsVersionChecker.matches?('>1.0.1')
          raise system_exit unless system_exit.is_a? Gem::SystemExitException
          exit_status = system_exit.message
        else
          raise system_exit
        end
      rescue GemInstaller::RubyGemsExit => normal_exit
        exit_status = normal_exit.message
      rescue GemInstaller::GemInstallerError => exit_error
        raise_error_with_output(exit_error, args, @output_listener)
      end
      output_lines = @output_listener.read!
      output_lines.push(exit_status) if exit_status
      output_lines.collect do |line|
        line.split("\n")
      end.flatten
    end
    
    def create_gem_runner
      if GemInstaller::RubyGemsVersionChecker.matches?('< 0.9')
        @gem_runner_class.new()
      else
        @gem_runner_class.new(:command_manager => @gem_cmd_manager_class)
      end
    end
        
    def raise_error_with_output(exit_error, args, listener)
      error_class = exit_error.class
      error_message = exit_error.message
      gem_command_output = listener.read!
      if gem_command_output.join('') =~ /Errno::EACCES/
        error_message = access_error_message + "\n" + error_message
        error_class = GemInstaller::GemInstallerAccessError
      end      
      descriptive_exit_message = exit_error.descriptive_exit_message(error_message, 'gem', args, gem_command_output)
      raise error_class.new(descriptive_exit_message)
    end
    
    def access_error_message
      "You don't have permission to install a gem.\nThis is not a problem with GemInstaller.\nYou probably want use the --sudo option or run GemInstaller as sudo,\nor install your gems to a non-root-owned location.\nSee http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo\n"
    end
  end
end
