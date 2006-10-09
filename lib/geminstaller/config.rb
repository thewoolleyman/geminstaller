dir = File.dirname(__FILE__)
require 'yaml'
require File.expand_path("#{dir}/ruby_gem")

module GemInstaller
  class Config
    SUPPORTED_GEMINSTALLER_VERSION = 1.0
    def initialize(yaml)
      @yaml = yaml
      check_geminstaller_version
    end

    def gems
      parse_defaults
      gem_defs = @yaml["gems"]
      gems = []
      gem_defs.each do |gem_def|
        name = gem_def['name']
        version = gem_def['version'].to_s
        # get install_options for specific gem, if specified
        install_options_string = gem_def['install_options'].to_s
        # if no install_options were specified for specific gem, and default install_options were specified...
        if install_options_string.empty? && @default_install_options_string then
          # then use the default install_options
          install_options_string = @default_install_options_string
        end
        install_options_array = []
        # if there was an install options string specified, default or gem-specific, parse it to an array
        if !install_options_string.empty? then
          install_options_array = install_options_string.split(" ")
        end
        gem = GemInstaller::RubyGem.new(name, version, install_options_array)
        gems << gem
      end
      return gems
    end

    protected

    def parse_defaults
      defaults = @yaml["defaults"]
      return if defaults.nil?
      @default_install_options_string = defaults['install_options']
    end

    def check_geminstaller_version
      geminstaller_version = @yaml['geminstaller_version']
      if geminstaller_version.nil? || geminstaller_version.to_s.empty? then
        raise RuntimeError, "You must specify a valid geminstaller_version at the beginning of the config file.  For example, 'geminstaller_version: #{SUPPORTED_GEMINSTALLER_VERSION}.  This is to ensure compatibility of config files with future releases."
      end

      if geminstaller_version > SUPPORTED_GEMINSTALLER_VERSION then
        raise RuntimeError, "#{geminstaller_version} is not a valid geminstaller_version.  You must specify a valid geminstaller_version at the beginning of the config file.  For example, 'geminstaller_version: #{SUPPORTED_GEMINSTALLER_VERSION}.  This is to ensure compatibility of config files with future releases."
      end
    end
  end
end