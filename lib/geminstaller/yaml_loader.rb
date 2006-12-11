module GemInstaller
  class YamlLoader
    def load(yaml_text)
      yaml = nil
      begin
        yaml = YAML.load(yaml_text)
      rescue
        raise GemInstaller::GemInstallerError.new("Error: Received error while attempting to parse YAML from yaml text.  Please ensure this is valid YAML:\n\n#{yaml_text}\n\n")
      end
      return yaml
    end
  end
end