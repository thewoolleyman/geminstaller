module GemInstaller
  class ArgParser
    attr_reader :output
    attr_writer :options
    
    def parse(args = [])
      raise GemInstaller::GemInstallerError.new("Args must be passed as an array.") unless args.nil? or args.respond_to? :shift
      args = ARGV if args.nil? || args == []

      @options[:verbose] = false
      @options[:quiet] = false
      @options[:info] = false
      @options[:sudo] = false
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

        opts.on("-q", "--quiet", "Suppress all output except severe errors or exceptions") do
          @options[:quiet] = true
        end

        opts.on("-v", "--verbose", "Show verbose output (such as exceptions from rubygems)") do
          @options[:verbose] = true
        end

        opts.on("-s", "--sudo", "Perform all gem operations under sudo (as root).  Will only work on correctly configured, supported systems.  See docs for more info") do
          @options[:sudo] = true
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
      
      if (@options[:sudo])
        @output = "The sudo option is not (yet) supported when invoking GemInstaller programatically.  It is only supported when using the command line 'geminstaller' executable.  See the docs for more info."
      end

      # nil out @output if there was no output
      @output = nil if @output == ""
      return @options
      
    end
  end
end