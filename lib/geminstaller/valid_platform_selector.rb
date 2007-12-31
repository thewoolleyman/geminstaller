module GemInstaller
  class ValidPlatformSelector
    attr_writer :options, :ruby_platform, :output_filter
    
    def select(gem_platform = nil, exact_platform_match = false)
      if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
        # valid_platform_selector is not used for RubyGems >= 0.9.5
        raise RuntimeError.new("Internal GemInstaller Error: ValidPlatformSelector should not be used for RubyGems >= 0.9.5")
      end

      @ruby_platform ||= RUBY_PLATFORM
      return [@ruby_platform] if gem_platform == Gem::Platform::CURRENT
      return [gem_platform] if exact_platform_match
      valid_platforms = []
      valid_platforms += binary_platform_substring if binary_platform_substring
      if @options[:prefer_binary_platform] == false
        # put ruby first if prefer_binary_platform is false
        valid_platforms.unshift('ruby')
      else
        # leave binary platform first if prefer_binary_platform is false or nil
        valid_platforms << 'ruby'
      end
      if gem_platform and 
        !valid_platforms.include?(gem_platform)
        # only prepend the gem_platform as the first choice if
        # 1. it is not nil
        # 2. it is not already in the list
        # 3. it is not 'ruby'
        valid_platforms.unshift(gem_platform)
      end
      message = "Selecting valid platform(s): @ruby_platform='#{@ruby_platform}', gem_platform='#{gem_platform}', valid_platforms='#{valid_platforms.inspect}'"
      @output_filter.geminstaller_output(:debug,"#{message}\n")
      valid_platforms
    end
    
    def binary_platform_substring
      return ['686-darwin'] if @ruby_platform =~ /686-darwin/
      return ['cygwin'] if @ruby_platform =~ /cygwin/
      return ['powerpc'] if @ruby_platform =~ /powerpc/
      return ['i386-mswin32','mswin32'] if @ruby_platform =~ /mswin/
      return ['386-linux'] if @ruby_platform =~ /386-linux/
      return ['486-linux'] if @ruby_platform =~ /486-linux/
      return ['586-linux'] if @ruby_platform =~ /586-linux/
      return ['686-linux'] if @ruby_platform =~ /686-linux/
      return ['solaris'] if @ruby_platform =~ /solaris/
      return nil
    end
  end
end