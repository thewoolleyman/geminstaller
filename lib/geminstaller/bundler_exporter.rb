module GemInstaller
  class BundlerExporter
    attr_writer :output_proxy
    
    def output(config)
      output_string = convert(config)
      @output_proxy.sysout output_string
      output_string
    end

    def convert(config)
      manifest = "source :gemcutter\n"
      config.gems.each do |gem|
        manifest += %Q{gem "#{gem.name}", "#{gem.version}"\n}
      end
      manifest
    end
  end
end