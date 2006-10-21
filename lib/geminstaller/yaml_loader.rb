module GemInstaller
  class YamlLoader
    def load(yaml_text)
      yaml = nil
      begin
        yaml = YAML.load(yaml_text)
      rescue
        $stderr.print "Error: Unable parse YAML from yaml text.  Please ensure this is valid YAML:\n\n#{yaml_text}\n\n"
        raise
      end
      return yaml
    end
  end
end