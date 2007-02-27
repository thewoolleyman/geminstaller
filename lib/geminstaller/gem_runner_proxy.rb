module GemInstaller
  class GemRunnerProxy
    attr_writer :gem_runner_class, :gem_cmd_manager_class, :output_listener_class
    attr_writer :options, :enhanced_stream_ui

    def run(args = [], stdin = [])
      gem_runner = create_gem_runner
      # We have to manually initialize the configuration here, or else the GemCommandManager singleton
      # will initialize with the (incorrect) default args when we call GemRunner.run.
      gem_runner.do_configuration(args)
      @gem_cmd_manager_class.instance.ui = @enhanced_stream_ui
      
      listener = create_output_listener
      stdout_output_listener = listener
      stderr_output_listener = listener
      if @options[:quiet]
        listener.echo = false
      end
      @enhanced_stream_ui.register_outs_listener(stdout_output_listener)
      @enhanced_stream_ui.register_errs_listener(stderr_output_listener)
      @enhanced_stream_ui.queue_input(stdin)
      exit_status = nil
      begin
        gem_runner.run(args)
      rescue GemInstaller::RubyGemsExit => normal_exit
        exit_status = normal_exit.message
      rescue GemInstaller::UnexpectedPromptError => unexpected_prompt_exit
        last_output_line = listener.read.last
        message = unexpected_prompt_exit.message
        if last_output_line.index('Install required dependency')
          message = "Error: RubyGems is prompting to install a required dependency, and you have not " +
                    "specified the '--install-dependencies' option for the current gem.  You must modify your " +
                    "geminstaller config file to either specify the '--install-depencencies' (-y) " +
                    "option, or explicitly add an entry for the dependency gem earlier in the file."
        end
        raise_error_with_output(unexpected_prompt_exit, message, listener, args)
      rescue GemInstaller::GemInstallerError => abnormal_exit
        raise_error_with_output(abnormal_exit, abnormal_exit.message, listener, args)
      end
      output_lines = listener.read!
      output_lines.push(exit_status) if exit_status
      return output_lines
    end
    
    def create_gem_runner
      rubygems_version = Gem::RubyGemsVersion
      if rubygems_version.index('0.8') == 0
        @gem_runner_class.new()
      else
        @gem_runner_class.new(:command_manager => @gem_cmd_manager_class)
      end
    end
    
    def create_output_listener
      @output_listener_class.new
    end
    
    def raise_error_with_output(exit_error, message, listener, args)
      args_string = args.join(" ")
      descriptive_exit_message = "\n#{message}\n"
      descriptive_exit_message += "Gem command was:\n  gem #{args_string}\n\n"
      descriptive_exit_message += "Gem command output was:\n"
      descriptive_exit_message += listener.read!.join("\n")
      descriptive_exit_message += "\n\n"
      raise exit_error.class.new(descriptive_exit_message)
    end
  end
end
