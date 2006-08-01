require 'yaml'

module GemInstaller
  class YamlLoader
    def initialize(yaml_text)
      @yaml_text = yaml_text
    end
    def load
      yaml = nil
      begin
        yaml = YAML.load(@yaml_text)
      rescue
        $stderr.print "Error: Unable parse YAML from yaml text.  Please ensure this is valid YAML:\n\n#{@yaml_text}\n\n"
        raise
      end
      return yaml
    end
  end
end