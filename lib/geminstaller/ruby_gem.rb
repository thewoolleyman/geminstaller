module GemInstaller
  class RubyGem
    attr_accessor :name
    attr_accessor :version
    attr_accessor :install_options


    def initialize(name, opts={})
      @name = name
      #TODO: the following logic could probably be more concise, but I'm not sure right now
      @version = GemInstaller::RubyGem.default_version
      if opts[:version] != "" && opts[:version] != nil 
        @version = opts[:version] 
      end
      @install_options = opts[:install_options] ||= []
    end

    def self.default_version
      '> 0.0.0'
    end

  end
end