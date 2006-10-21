module GemInstaller
  class Config
    SUPPORTED_GEMINSTALLER_VERSION = 1.0
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
        gem = GemInstaller::RubyGem.new(name, :version => version, :install_options => install_options_array)
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
  end
end