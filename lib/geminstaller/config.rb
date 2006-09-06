require 'yaml'
require 'geminstaller/gem'

module GemInstaller
  class Config
    def initialize(yaml)
      @yaml = yaml
    end

    def gems
      parse_defaults
      gem_defs = @yaml["gems"]
      gems = []
      gem_defs.each do |gem_def|
        name = gem_def['name']
        version = gem_def['version'].to_s
        # get install_options for specific gem, if specified
        install_options = gem_def['install_options'].to_s
        # if no install_options were specified for specific gem, and default install_options were specified...
        if install_options.empty? && @default_install_options then
          # then use the default install_options
          install_options = @default_install_options
        end
        gem = GemInstaller::Gem.new(name, version, install_options)
        gems << gem
      end
      return gems
    end

    protected

    def parse_defaults
      defaults = @yaml["defaults"]
      return if defaults.nil?
      @default_install_options = defaults['install_options']
    end
  end
end