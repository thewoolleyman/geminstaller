module GemInstaller
  class OutputFilter
    attr_writer :output_proxy, :options
    
    def rubygems_output(type, message)
      return if @options[:silent]
      return unless rubygems_output_type_matches?(type)
      output(:rubygems, type, message)
    end
      
    def geminstaller_output(type, message)
      return if @options[:silent]
      return unless geminstaller_output_type_matches?(type)
      output(:geminstaller, type, message)
    end
      
    def output(source, type, message)
      message = format_rubygems_message(type,message) if source == :rubygems
      @output_proxy.sysout(message)
    end
    
    def format_rubygems_message(type, message)
      prefix = case type
      when :stdout : "[RubyGems:stdout] "
      when :stderr : "[RubyGems:stderr] "
      end
      "#{prefix}#{message}"
    end

    def rubygems_output_type_matches?(type)
      return false unless @options[:rubygems_output]
      return true if @options[:rubygems_output].include?(:all)
      return true if @options[:rubygems_output].include?(type)
      return false
    end

    def geminstaller_output_type_matches?(type)
      return true if @options[:geminstaller_output].include?(type)
      return false
    end
  end
end