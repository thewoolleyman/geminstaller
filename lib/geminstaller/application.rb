module GemInstaller
  class Application
    # we have accessors instead of just writers so that we can ensure it is assembled correctly in the dependency injector test
    attr_accessor :config_builder, :install_processor, :output_filter, :arg_parser, :args, :options
    attr_writer :autogem
    
    def initialize
      @args = nil
    end
    
    def run
      begin
        exit_flag_and_return_code = handle_args
        if exit_flag_and_return_code[0]
          return exit_flag_and_return_code[1]
        end
        config = @config_builder.build_config
        gems = config.gems
        print_startup_message(gems) unless @options[:silent]
        @install_processor.process(gems)
      rescue Exception => e
        message = e.message
        message += "\n"
        @output_filter.geminstaller_output(:error,message)
        backtrace_as_string = e.backtrace.join("\n")
        @output_filter.geminstaller_output(:error,"#{backtrace_as_string}\n")
        return 1
      end
      return 0
    end
    
    def autogem
      # TODO: do some validation that args only contains --config option
      handle_args
      config = @config_builder.build_config
      gems = config.gems
      @autogem.autogem(gems)
    end

    def handle_args
      return_code = @arg_parser.parse(@args)
      arg_parser_output = @arg_parser.output
      if (arg_parser_output && arg_parser_output != '')
        if return_code == 0
          @output_filter.geminstaller_output(:info,arg_parser_output)
        else
          @output_filter.geminstaller_output(:error,arg_parser_output)
        end
        return [true, return_code]
      end
      config_file_paths = @options[:config_paths]
      @config_builder.config_file_paths = config_file_paths if config_file_paths
      return [false, 0]
    end

    def print_startup_message(gems)
      message = "GemInstaller is verifying gem installation: "
      gems.each_with_index do |gem, index|
        gem_info = "#{gem.name} #{gem.version}"
        message += gem_info 
        message += ", " if index + 1 < gems.size
      end
      @output_filter.geminstaller_output(:info,message + "\n")
    end
  end
end