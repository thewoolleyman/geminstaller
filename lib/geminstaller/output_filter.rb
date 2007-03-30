module GemInstaller
  class OutputFilter
    attr_writer :output_proxy, :options
    
    def rubygems_output(type, message)
      output(:rubygems, type, message)
    end
      
    def output(source, type, message)
      return unless type_matches?(type)
      formatted_message = format_message(source,message)
      @output_proxy.sysout(formatted_message)
    end
    
    def format_message(source, message)
      prefix = case source
      when :rubygems : "[RubyGems]"
      end
      "#{prefix} #{message}"
    end

    def type_matches?(type)
      return true if @options[:rubygems_output].include?(type)
    end
  end
end