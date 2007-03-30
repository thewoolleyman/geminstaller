module GemInstaller
  class Application
    # we have accessors instead of just writers so that we can ensure it is assembled correctly in the dependency injector test
    attr_accessor :config_builder, :install_processor, :output_proxy, :arg_parser, :args, :options
    
    def initialize
      @args = nil
    end
    
    def run
      begin
        should_exit = handle_args
        return 0 if should_exit
        config = @config_builder.build_config
        gems = config.gems
        print_startup_message(gems) unless @options[:quiet]
        @install_processor.process(gems)
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
    
    def autogem
      # TODO: do some validation that args only contains --config option
      handle_args
      config = @config_builder.build_config
      gems = config.gems
      reversed_gems = gems.reverse!
      completed_names = []
      completed_gems = []
      reversed_gems.each do |gem|
        unless completed_names.index(gem.name)
          invoke_require_gem_command(gem.name, gem.version)
          completed_names << gem.name
          completed_gems << gem
        end
      end
      completed_gems
    end
    
    def invoke_require_gem_command(name, version)
      if Gem::RubyGemsVersion.index('0.8') == 0
        require_gem(name, version)
      else
        gem(name, version)
      end
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