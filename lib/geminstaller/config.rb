require 'yaml'

module GemInstaller
  class Config
    def initialize(config_file = "geminstaller.yml")
      begin
        flag = File.exist?('geminstaller.yml')
        file = File.open(config_file)
        @config = YAML.load(file)
      rescue
        $stderr.print "Error: Unable to load or parse YAML config file #{config_file}.  Please ensure this file exists, and is a valid YAML file.\n\n"
        raise
      end
    end
    def required_gems
      gem_defs = @config["gems"]
      gem_list = []
      gem_defs.each do |gem_def|
        gem_list << gem_def["name"]
      end
      return gem_list
    end
  end
end