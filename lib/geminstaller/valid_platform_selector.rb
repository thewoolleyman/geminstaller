module GemInstaller
  class ValidPlatformSelector
    attr_writer :prefer_binary_platform
    attr_writer :ruby_platform
    
    def select(dependent_gem_platform = nil)
      @ruby_platform ||= RUBY_PLATFORM
      valid_platforms = []
      valid_platforms << binary_platform_substring if binary_platform_substring
      if @prefer_binary_platform
        valid_platforms << 'ruby'
      else
        valid_platforms.unshift('ruby')
      end
      valid_platforms.unshift(dependent_gem_platform) if 
        dependent_gem_platform && dependent_gem_platform != @ruby_platform
      valid_platforms
    end
    
    def binary_platform_substring
      return '686-darwin' if @ruby_platform =~ /686-darwin/
      return 'cygwin' if @ruby_platform =~ /cygwin/
      return 'powerpc' if @ruby_platform =~ /powerpc/
      return 'mswin' if @ruby_platform =~ /mswin/
      return '386-linux' if @ruby_platform =~ /386-linux/
      return '486-linux' if @ruby_platform =~ /486-linux/
      return '586-linux' if @ruby_platform =~ /586-linux/
      return '686-linux' if @ruby_platform =~ /686-linux/
      return nil
    end
  end
end