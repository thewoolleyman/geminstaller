module GemInstaller
  class OutputFilter
    attr_writer :output_proxy, :options
    
    def rubygems_output(type, message)
      return unless rubygems_output_type_matches?(type)
      output(:rubygems, type, message)
    end
      
    def geminstaller_output(type, message)
      return unless geminstaller_output_type_matches?(type)
      output(:geminstaller, type, message)
    end
      
    def output(source, type, message)
      formatted_message = format_message(source,message)
      @output_proxy.sysout(formatted_message)
    end
    
    def format_message(source, message)
      prefix = case source
      when :rubygems : "[RubyGems] "
      end
      "#{prefix}#{message}"
    end

    def rubygems_output_type_matches?(type)
      return true if @options[:rubygems_output].include?(type)
      return false
    end

    def geminstaller_output_type_matches?(type)
      return true if @options[:geminstaller_output].include?(type)
      return false
    end
  end
end