module GemInstaller
  class ArgParser
    attr_reader :output
    attr_writer :options
    
    VALID_GEMINSTALLER_OUTPUT_FLAGS = [:none,:error,:install,:info,:commandecho,:debug,:all]
    VALID_RUBYGEMS_OUTPUT_FLAGS = [:none,:stdout,:stderr,:all]
    
    def parse(args = [])
      raise GemInstaller::GemInstallerError.new("Args must be passed as an array.") unless args.nil? or args.respond_to? :shift
      args = ARGV if args.nil? || args == []

      @options[:silent] = false
      @options[:sudo] = false
      @options[:geminstaller_output] = [:error,:install,:info]
      @options[:rubygems_output] = [:stderr]
      @output = ""
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: geminstaller [options]"

        opts.separator ""

        opts.on("-cCONFIGPATHS", "--config=CONFIGPATHS", String, "Comma-delimited path(s) to GemInstaller config file(s)") do |config_paths|
          @options[:config_paths] = config_paths
        end

        opts.on("-gGEMINSTALLER_OUTPUT", "--geminstaller-output=GEMINSTALLER_OUTPUT", String, "Types of output to show from GemInstaller.") do |geminstaller_output_flags|
          @unparsed_geminstaller_output_flags = geminstaller_output_flags
        end

        opts.on_tail("-h", "--help", "Show this message") do
          @output = opts.to_s
        end

        opts.on("-p", "--print-rogue-gems", "Print a report of all locally installed gems which are not specified in the geminstaller config file") do
          @options[:print_rogue_gems] = true
        end

        opts.on("-rRUBYGEMS_OUTPUT", "--rubygems-output=RUBYGEMS_OUTPUT", String, "Types of output to show from internal RubyGems command invocation.") do |rubygems_output_flags|
          @unparsed_rubygems_output_flags = rubygems_output_flags
        end

        opts.on("-s", "--sudo", "Perform all gem operations under sudo (as root).  Will only work on correctly configured, supported systems.  See docs for more info") do
          @options[:sudo] = true
        end

        opts.on("-t", "--silent", "Suppress all output except fatal exceptions, and output from rogue-gems option") do
          @options[:silent] = true
        end

        opts.on_tail("-v", "--version", "Show GemInstaller version") do
          @output = GemInstaller::version
        end
      end

      begin
        opts.parse!(args)
      rescue(OptionParser::InvalidOption)
        @output << opts.to_s
        return -1
      end
      
      if @options[:silent] and (@unparsed_geminstaller_output_flags or @unparsed_rubygems_output_flags)
        @output = "The rubygems-output or geminstaller-output option cannot be specified if the silent option is true."
        return -1
      end

      if (@options[:sudo])
        @output = "The sudo option is not (yet) supported when invoking GemInstaller programatically.  It is only supported when using the command line 'geminstaller' executable.  See the docs for more info."
        return -1
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
            @output = "Invalid geminstaller-output flag: #{flag}" 
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
            @output = "Invalid rubygems-output flag: #{flag}" 
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