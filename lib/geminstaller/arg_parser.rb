module GemInstaller
  class ArgParser
    attr_reader :output
    @options = {}
    
    def parse(args)
      @output = ""
      opts = OptionParser.new do |opts|
        opts.banner = "Usage: geminstaller [options]"

        opts.separator ""
        opts.separator "Specific options:"

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
      
      return @options
      
    end
  end
end