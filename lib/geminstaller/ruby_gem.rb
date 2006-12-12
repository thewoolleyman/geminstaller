module GemInstaller
  class RubyGem
    include Comparable
    attr_accessor :name
    attr_accessor :version
    attr_accessor :platform
    attr_accessor :install_options

    def initialize(name, opts={})
      @name = name
      #TODO: the following logic could probably be more concise, but I'm not sure right now
      @version = GemInstaller::RubyGem.default_version
      if opts[:version] != "" && opts[:version] != nil 
        @version = opts[:version] 
      end
      @platform = 'ruby'
      if opts[:platform] != "" && opts[:platform] != nil 
        @platform = opts[:platform]
      end
      @install_options = opts[:install_options] ||= []
    end

    def self.default_version
      '> 0.0.0'
    end

    def <=>(other)
      compare = @name <=> other.name
      return compare if compare != 0
      compare = @version <=> other.version
      return compare if compare != 0
      return @platform <=> other.platform
    end 
  end
end