module GemInstaller
  class ArgParser
    attr_reader :output
    attr_writer :options
    
    VALID_GEMINSTALLER_OUTPUT_FLAGS = [:none,:error,:install,:info,:commandecho,:debug,:all]
    VALID_RUBYGEMS_OUTPUT_FLAGS = [:none,:stdout,:stderr,:all]
    
    def parse(args = [])
      raise GemInstaller::GemInstallerError.new("Args must be passed as an array.") unless args.nil? or args.respond_to? :shift
      args = ARGV if args.nil? || args == []

      @options[:exceptions] = false
      @options[:redirect_stderr_to_stdout] = false
      @options[:silent] = false
      @options[:sudo] = false
      @options[:geminstaller_output] = [:error,:install,:info]
      @options[:rubygems_output] = [:stderr]
      @output = ""
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: geminstaller [options]"

        opts.separator ""

        config_msg =                         "Comma-delimited path(s) to GemInstaller config file(s)."
        exceptions_msg =                     "Raise any exceptions, rather than just printing them and exiting\n" +
        "                                     with a non-zero return code."
        redirect_stderr_to_stdout_msg =      "Redirect all STDERR output to STDOUT.  Useful to get all output when\n" +
        "                                     invoking GemInstaller via system()."
        geminstaller_output_msg =            "Comma-delimited list of output types to show from GemInstaller.\n" +
        "                                       Examples:\n" + 
        "                                         --gall\n" +
        "                                         --geminstaller-output=error,install,commandecho\n" +
        "                                       Default: error,install,info\n" +
        "                                       Valid types:\n" +
        "                                         - none:        print only fatal errors\n" +
        "                                         - error:       print error messages\n" +
        "                                         - install:     print install messages\n" +
        "                                         - info:        print informational messages\n" +
        "                                         - commandecho: print rubygems commands as they are invoked\n" +
        "                                         - debug:       print debug messages\n" +
        "                                         - all:         print all messages"
        help_msg =                           "Show this message."
        print_rogue_gems_msg =               "Print a report of all locally installed gems which are not specified\n" +
        "                                     in the geminstaller config file."
        rubygems_output_msg =                "Comma-delimited list of output types to show from internal:\n" +
        "                                       RubyGems command invocation.\n" +
        "                                       Examples:\n" + 
        "                                         --rall\n" +
        "                                         --rubygems-output=stderr\n" +
        "                                       Default: stderr\n" +
        "                                       Valid types:\n" +
        "                                         - none:        print no output\n" +
        "                                         - stdout:      print standard output stream\n" +
        "                                         - stderr:      print standard error stream\n" +
        "                                         - all:         print all output"
        sudo_msg =                           "Perform all gem operations under sudo (as root).  Will only work on\n" +
        "                                     correctly configured, supported systems.  See docs for more info."
        silent_msg =                         "Suppress all output except fatal exceptions, and output from\n" +
        "                                     rogue-gems option."
        version_msg =                        "Show GemInstaller version and exit."

        opts.on("-cCONFIGPATHS", "--config=CONFIGPATHS", String, config_msg) do |config_paths|
          @options[:config_paths] = config_paths
        end

        opts.on("-e", "--exceptions", exceptions_msg) do
          @options[:exceptions] = true
        end

        opts.on("-d", "--redirect-stderr-to-stdout", redirect_stderr_to_stdout_msg) do
          @options[:redirect_stderr_to_stdout] = true
        end

        opts.on("-gTYPES", "--geminstaller-output=TYPES", String, geminstaller_output_msg) do |geminstaller_output_flags|
          @unparsed_geminstaller_output_flags = geminstaller_output_flags
        end

        opts.on("-h", "--help", help_msg) do
          @output = opts.to_s
        end

        opts.on("-p", "--print-rogue-gems", print_rogue_gems_msg) do
          @options[:print_rogue_gems] = true
        end

        opts.on("-rTYPES", "--rubygems-output=TYPES", String, rubygems_output_msg) do |rubygems_output_flags|
          @unparsed_rubygems_output_flags = rubygems_output_flags
        end

        opts.on("-s", "--sudo", sudo_msg) do
          @options[:sudo] = true
        end

        opts.on("-t", "--silent", silent_msg) do
          @options[:silent] = true
        end

        opts.on("-v", "--version", version_msg) do
          @output = "#{GemInstaller::version}\n"
        end
      end

      begin
        opts.parse!(args)
      rescue(OptionParser::InvalidOption)
        @output << opts.to_s
        return 1
      end
      
      if @options[:silent] and (@unparsed_geminstaller_output_flags or @unparsed_rubygems_output_flags)
        @output = "The rubygems-output or geminstaller-output option cannot be specified if the silent option is true."
        return 1
      end

      if (@options[:sudo])
        @output = "The sudo option is not (yet) supported when invoking GemInstaller programatically.  It is only supported when using the command line 'geminstaller' executable.  See the docs for more info."
        return 1
      end
      
      # TODO: remove duplication
      if @unparsed_geminstaller_output_flags
        flags = @unparsed_geminstaller_output_flags.split(',') 
        flags.delete_if {|flag| flag == nil or flag == ''}
        flags.map! {|flag| flag.downcase}
        flags.sort!
        flags.uniq!
        flags.map! {|flag| flag.to_sym}
        geminstaller_output_valid = true
        flags.each do |flag|
          unless VALID_GEMINSTALLER_OUTPUT_FLAGS.include?(flag)
            @output = "Invalid geminstaller-output flag: #{flag}\n" 
            geminstaller_output_valid = false
          end
        end
        @options[:geminstaller_output] = flags if geminstaller_output_valid
      end

      if @unparsed_rubygems_output_flags
        flags = @unparsed_rubygems_output_flags.split(',') 
        flags.delete_if {|flag| flag == nil or flag == ''}
        flags.map! {|flag| flag.downcase}
        flags.sort!
        flags.uniq!
        flags.map! {|flag| flag.to_sym}
        rubygems_output_valid = true
        flags.each do |flag|
          unless VALID_RUBYGEMS_OUTPUT_FLAGS.include?(flag)
            @output = "Invalid rubygems-output flag: #{flag}\n" 
            rubygems_output_valid = false
          end
        end
        @options[:rubygems_output] = flags if rubygems_output_valid
      end

      # nil out @output if there was no output
      @output = nil if @output == ""
      return 0
      
    end
  end
end