module GemInstaller
  class RubyGem
    include Comparable
    attr_accessor :name, :version, :platform, :install_options, :check_for_upgrade, :fix_dependencies, :no_autogem, :prefer_binary_platform, :uninstall_options

    def initialize(name, opts={})
      @name = name
      #TODO: the following logic could probably be more concise, but I'm not sure right now
      @version = GemInstaller::RubyGem.default_version
      if opts[:version] != "" && opts[:version] != nil 
        @version = opts[:version] 
      end
      if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.5')
        @platform = 'ruby'
      end
      if opts[:platform] != "" && opts[:platform] != nil 
        @platform = opts[:platform]
      end
      @install_options = opts[:install_options] ||= []
      @uninstall_options = opts[:uninstall_options] ||= []
      @check_for_upgrade = opts[:check_for_upgrade] == true ? true : false
      @fix_dependencies = opts[:fix_dependencies] == true ? true : false
      @no_autogem = opts[:no_autogem] == true ? true : false
      if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
        warn("The 'prefer_binary_platform' option is deprecated on RubyGems >= 0.9.5, and has no effect") unless opts[:prefer_binary_platorm].nil?
      else
        @prefer_binary_platform = opts[:prefer_binary_platorm] == false ? false : true
      end
    end

    def self.default_version
      '> 0.0.0'
    end
    
    def self.default_platform
      if GemInstaller::RubyGemsVersionChecker.matches?('>0.9.5')
        Gem::Platform::CURRENT
      else
        # Not sure if this is actually required for RubyGems <=0.9.5, but it 
        # was the original value in GemInstaller <=0.3.0, and makes the tests pass
        'ruby'
      end
    end

    def <=>(other)
      compare = @name <=> other.name
      return compare if compare != 0
      compare = @version <=> other.version
      return compare if compare != 0
      return 0 if (@platform == nil && other.platform == nil)
      return @platform <=> other.platform
    end
    
    def regexp_escaped_name
      Regexp.escape(@name)
    end
  end
end