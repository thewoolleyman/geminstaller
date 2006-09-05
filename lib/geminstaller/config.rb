require 'yaml'
require 'geminstaller/gem'

module GemInstaller
  class Config
    def initialize(yaml)
      @yaml = yaml
    end

    def gems
      gem_defs = @yaml["gems"]
      gems = []
      gem_defs.each do |gem_def|
        name = gem_def['name']
        version = gem_def['version'].to_s
        gem = GemInstaller::Gem.new(name, version)
        gems << gem
      end
      return gems
    end
  end
end