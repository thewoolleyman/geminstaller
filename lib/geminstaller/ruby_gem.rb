require 'yaml'

module GemInstaller
  class RubyGem
    attr_accessor :name
    attr_accessor :version
    attr_accessor :install_options


    def initialize(name, opts={})
      @name = name
      @version = opts[:version] ||= default_version
      @install_options = opts[:install_options] ||= []
    end

    def default_version
      '> 0.0.0'
    end

  end
end