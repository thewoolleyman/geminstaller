module GemInstaller
  class Application
    # we have accessors instead of just writers so that we can ensure it is assembled correctly in the dependency injector test
    attr_accessor :config_builder, :gem_command_manager, :gem_list_checker, :output_proxy, :arg_parser, :args
    
    def self.default_args
      ARGV
    end

    def run
      begin
        handle_args
        config = @config_builder.build_config
        gems = config.gems
        gems.each do |gem|
          already_specified = false
          if gem.check_for_upgrade
            @gem_list_checker.verify_and_specify_remote_gem!(gem)
            already_specified = true
          end
          gem_is_installed = @gem_command_manager.is_gem_installed(gem)
          if gem_is_installed && @info
            @output_proxy.sysout("Gem #{gem.name}, version #{gem.version} is already installed.\n")
          end
          unless gem_is_installed
            @gem_list_checker.verify_and_specify_remote_gem!(gem) unless already_specified
            @output_proxy.sysout("Installing gem #{gem.name}, version #{gem.version}.\n") if @info
            @gem_command_manager.install_gem(gem)
          end
        end
      rescue Exception => e
        message = e.message
        message += "\n"
        @output_proxy.syserr(message)
        @output_proxy.syserr(e) if @verbose
        return 1
      end
      return 0
    end
    
    def handle_args
      @verbose = false
      raise GemInstaller::GemInstallerError.new("Args must be passed as an array.") unless @args.respond_to? :shift
      @args ||= GemInstaller::Application.default_args
      opts = @arg_parser.parse(@args)
      arg_parser_output = arg_parser.output
      if (arg_parser_output && arg_parser_output != '')
        raise GemInstaller::GemInstallerError.new(arg_parser_output)
      end
      if (opts[:sudo])
        err_msg = "The sudo option is not (yet) supported when invoking GemInstaller programatically.  It is only supported when using the command line 'geminstaller' executable."
        raise GemInstaller::GemInstallerError.new(err_msg)
      end
      if (opts)
        config_file_paths = opts[:config_paths]
        @config_builder.config_file_paths = config_file_paths if config_file_paths
        @verbose = opts[:verbose]
        @info = opts[:info]
      end
    end
  end
end