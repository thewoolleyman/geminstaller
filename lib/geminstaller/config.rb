require 'yaml'

module GemInstaller
  class Config
    def initialize(yaml)
      @yaml = yaml
    end

    def required_gems
      gem_defs = @yaml["gems"]
      gem_list = []
      gem_defs.each do |gem_def|
        gem_list << gem_def["name"]
      end
      return gem_list
    end
  end
end