module GemInstaller
  class GemRunnerProxy
    attr_writer :gem_runner_class, :gem_cmd_manager_class, :output_listener
    attr_writer :options, :enhanced_stream_ui

    def run(args = [], stdin = [])
      gem_runner = create_gem_runner
      # We have to manually initialize the configuration here, or else the GemCommandManager singleton
      # will initialize with the (incorrect) default args when we call GemRunner.run.
      gem_runner.do_configuration(args)
      @gem_cmd_manager_class.instance.ui = @enhanced_stream_ui
      
      exit_status = nil
      begin
        gem_runner.run(args)
      rescue GemInstaller::RubyGemsExit => normal_exit
        exit_status = normal_exit.message
      rescue GemInstaller::GemInstallerError => exit_error
        raise_error_with_output(exit_error, args, @output_listener)
      end
      output_lines = @output_listener.read!
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
        
    def raise_error_with_output(exit_error, args, listener)
      descriptive_exit_message = exit_error.descriptive_exit_message(exit_error.message, 'gem', args, listener)
      raise exit_error.class.new(descriptive_exit_message)
    end
  end
end
