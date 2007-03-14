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