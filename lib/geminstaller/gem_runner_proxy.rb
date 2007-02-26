module GemInstaller
  class GemRunnerProxy
    attr_writer :gem_runner_class, :gem_cmd_manager_class, :output_listener_class
    attr_writer :options, :enhanced_stream_ui

    def run(args = [], stdin = [])
      gem_runner = @gem_runner_class.new(:command_manager => @gem_cmd_manager_class)
      # We have to manually initialize the configuration here, or else the GemCommandManager singleton
      # will initialize with the (incorrect) default args when we call GemRunner.run.
      gem_runner.do_configuration(args)
      @gem_cmd_manager_class.instance.ui = @enhanced_stream_ui
      
      listener = @output_listener_class.new
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
      rescue GemInstaller::GemInstallerError => abnormal_exit
        raise_error_with_output(abnormal_exit.message, listener, args)
      end
      output_lines = listener.read!
      output_lines.push(exit_status) if exit_status
      return output_lines
    end
    
    def raise_error_with_output(exit_status, listener, args)
      args_string = args.join(" ")
      error_message = "\n#{exit_status}\n"
      error_message += "Gem command was:\n  gem #{args_string}\n\n"
      error_message += "Gem command output was:\n"
      error_message += listener.read!.join("\n")
      error_message += "\n\n"
      raise GemInstaller::GemInstallerError.new(error_message)
    end
  end
end
