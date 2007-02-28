module GemInstaller
  class Application
    # we have accessors instead of just writers so that we can ensure it is assembled correctly in the dependency injector test
    attr_accessor :config_builder, :gem_command_manager, :gem_list_checker, :output_proxy, :arg_parser, :args, :options
    
    def run
      begin
        should_exit = handle_args
        return 0 if should_exit
        config = @config_builder.build_config
        gems = config.gems
        print_startup_message(gems) unless @options[:quiet]
        gems.each do |gem|
          already_specified = false
          if gem.check_for_upgrade
            @gem_list_checker.verify_and_specify_remote_gem!(gem)
            already_specified = true
          end
          gem_is_installed = @gem_command_manager.is_gem_installed(gem)
          if gem_is_installed && @options[:info]
            @output_proxy.sysout("Gem #{gem.name}, version #{gem.version} is already installed.\n")
          end
          unless gem_is_installed
            @gem_list_checker.verify_and_specify_remote_gem!(gem) unless already_specified
            @output_proxy.sysout("Installing gem #{gem.name}, version #{gem.version}.\n") if @options[:info]
            @gem_command_manager.install_gem(gem)
          end
        end
      rescue Exception => e
        message = e.message
        message += "\n"
        @output_proxy.syserr(message)
        if @options[:verbose]
          backtrace_as_string = e.backtrace.join("\n")
          @output_proxy.syserr("#{backtrace_as_string}\n")
        end
        return 1
      end
      return 0
    end
    
    def handle_args
      @arg_parser.parse(@args)
      arg_parser_output = @arg_parser.output
      if (arg_parser_output && arg_parser_output != '')
        @output_proxy.sysout(arg_parser_output)
        return true
      end
      config_file_paths = @options[:config_paths]
      @config_builder.config_file_paths = config_file_paths if config_file_paths
      return false
    end

    def print_startup_message(gems)
      message = "GemInstaller is verifying gem installation: "
      gems.each_with_index do |gem, index|
        gem_info = "#{gem.name} #{gem.version}"
        message += gem_info 
        message += ", " if index + 1 < gems.size
      end
      @output_proxy.sysout(message + "\n")
    end
  end
end