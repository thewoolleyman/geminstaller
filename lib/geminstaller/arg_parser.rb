module GemInstaller
  class ArgParser
    attr_reader :output
    
    def parse(args)
      @options = {}
      @options[:verbose] = false
      @output = ""
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: geminstaller [options]"

        opts.separator ""

        opts.on("-cCONFIGPATH", "--config=CONFIGPATH", String, "Path to GemInstaller config file") do |config_path|
          @options[:config_path] = config_path
        end

        opts.on("-v", "--verbose", "Show verbose output") do
          @options[:verbose] = true
        end

        opts.on_tail("-h", "--help", "Show this message") do
          @output = opts.to_s
        end

        # TODO: automatically read current version
        #opts.on_tail("-v", "--version", "Show version") do
        #  @output = GemInstaller::Version.join('.')
        #end
      end

      begin
        opts.parse!(args)
      rescue(OptionParser::InvalidOption)
        @output << opts.to_s
        return @options
      end

      # nil out @output if there was no output
      @output = nil if @output == ""
      return @options
      
    end
  end
end