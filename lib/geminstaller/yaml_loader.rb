module GemInstaller
  class YamlLoader
    def load(yaml_text)
      yaml = nil
      begin
        yaml = YAML.load(yaml_text)
      rescue Exception => e
        message = e.message
        error = <<-STRING_END
Error: Received error while attempting to parse YAML from yaml text:
  #{message}
Please ensure this is valid YAML:

#{yaml_text}\n\n"
STRING_END

        raise GemInstaller::GemInstallerError.new(error)
      end
      return yaml
    end
  end
end