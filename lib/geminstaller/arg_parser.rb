module GemInstaller
  class ArgParser
    attr_reader :output
    attr_writer :options
    
    VALID_RUBYGEMS_OUTPUT_FLAGS = [:stdout,:stderr,:all]
    
    def parse(args = [])
      raise GemInstaller::GemInstallerError.new("Args must be passed as an array.") unless args.nil? or args.respond_to? :shift
      args = ARGV if args.nil? || args == []

      @options[:verbose] = false
      @options[:silent] = false
      @options[:info] = false
      @options[:sudo] = false
      @options[:geminstaller_output] = {}
      @options[:rubygems_output] = {}
      @output = ""
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: geminstaller [options]"

        opts.separator ""

        opts.on("-i", "--info", "Show informational output, such as whether a gem is already installed.") do
          @options[:info] = true
        end

        opts.on("-cCONFIGPATHS", "--config=CONFIGPATHS", String, "Comma-delimited path(s) to GemInstaller config file(s)") do |config_paths|
          @options[:config_paths] = config_paths
        end

        opts.on("-t", "--silent", "Suppress all output except fatal exceptions") do
          @options[:silent] = true
        end

        opts.on("-s", "--sudo", "Perform all gem operations under sudo (as root).  Will only work on correctly configured, supported systems.  See docs for more info") do
          @options[:sudo] = true
        end

        opts.on("-v", "--verbose", "Show verbose output (such as exceptions from rubygems)") do
          @options[:verbose] = true
        end

        opts.on("-V=RUBYGEMS_OUTPUT", "--rubygems-output=RUBYGEMS_OUTPUT", String, "Types of output to show from internal RubyGems command invocation.") do |rubygems_output_flags|
          @unparsed_rubygems_output_flags = rubygems_output_flags
        end

        opts.on_tail("-h", "--help", "Show this message") do
          @output = opts.to_s
        end

        opts.on_tail("--version", "Show version") do
          @output = GemInstaller::version
        end
      end

      begin
        opts.parse!(args)
      rescue(OptionParser::InvalidOption)
        @output << opts.to_s
        return @options
      end
      
      if @options[:silent] and (@unparsed_geminstaller_output_flags or @unparsed_rubygems_output_flags)
        @output = "The rubygems-output or geminstaller-output option cannot be specified if the silent option is true."
      elsif @unparsed_rubygems_output_flags
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
      elsif (@options[:sudo])
        @output = "The sudo option is not (yet) supported when invoking GemInstaller programatically.  It is only supported when using the command line 'geminstaller' executable.  See the docs for more info."
      end

      # nil out @output if there was no output
      @output = nil if @output == ""
      return @options
      
    end
  end
end