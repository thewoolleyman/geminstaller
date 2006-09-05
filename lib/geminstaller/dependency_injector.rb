require 'needle'
require 'geminstaller/application'
require 'geminstaller/config'
require 'geminstaller/file_reader'
require 'geminstaller/yaml_loader'

module GemInstaller
  class DependencyInjector
    def create_application
      # define properties
      default_config_file_path = 'geminstaller.yml'

      # define the service registry
      registry = Needle::Registry.define! do |b|
        # register all services with the builder b
        b.file_reader { FileReader.new(default_config_file_path) }
        b.yaml_loader { YamlLoader.new(file_reader.read) }
        b.config { Config.new(b.yaml_loader.load) }

        b.app do
          app = GemInstaller::Application.new
          app.config = b.config
          app
        end
      end

      registry.app
    end
  end
end