module GemInstaller
  class Application
    # we have accessors instead of just writers so that we can ensure it is assembled correctly in the dependency injector test
    attr_accessor :config_builder, :install_processor, :output_filter, :arg_parser, :args, :options, :rogue_gem_finder
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
        gems = create_gems_from_config
        if @options[:print_rogue_gems]
          @rogue_gem_finder.print_rogue_gems(gems, @config_builder.config_file_paths_array)
          return 0
        end
        if gems.size == 0
          message = "No gems found in config file.  Try the --print-rogue-gems option to help populate your config file."
          @output_filter.geminstaller_output(:info,message + "\n")          
        else
          process_gems(gems)
        end
      rescue Exception => e
        handle_exception(e)
        return 1
      end
      return 0
    end
    
    def autogem
      begin
        # TODO: do some validation that args only contains --config option, especially not print_rogue_gems since this would mask a missing file error
        # TODO: this should check exit_flag_and_return_code just like run method
        handle_args
        gems = create_gems_from_config
        return @autogem.autogem(gems)
      rescue Exception => e
        handle_exception(e)
        return 1
      end
    end
    
    def handle_exception(e)
      message = e.message
      message += "\n"
      @output_filter.geminstaller_output(:error,message)
      backtrace_as_string = e.backtrace.join("\n")
      @output_filter.geminstaller_output(:debug,"#{backtrace_as_string}\n")
      raise e if @options[:exceptions]
    end
    
    def create_gems_from_config
      begin
        config = @config_builder.build_config
      rescue GemInstaller::MissingFileError => e
        # if user wants to print rogue gems and they have no config at all, don't show an error
        return [] if @options[:print_rogue_gems] && (@config_builder.config_file_paths_array.size == 1) 
        missing_path = e.message
        error_message = "Error: A GemInstaller config file is missing at #{missing_path}.  You can generate one with the --print-rogue-gems option.  See the GemInstaller docs at http://geminstaller.rubyforge.org for more info."
        raise GemInstaller::MissingFileError.new(error_message)
      end
      config.gems
    end
    
    def process_gems(gems)
      # TODO: silent check is unnecessary, output_filter handles it
      print_startup_message(gems)
      @install_processor.process(gems)
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