require 'needle'
require 'geminstaller/application'
require 'geminstaller/config'
require 'geminstaller/file_reader'
require 'geminstaller/yaml_loader'

module GemInstaller
  class DependencyInjector
    def config_file_path=(config_file_path)
      @config_file_path = config_file_path
    end

    def self.config_file_path
      @config_file_path
    end

    def create_application
      # define properties
      # Note: we have to define a local variable for config_file_path, Needle can't reference the instance variable
      config_file_path = @config_file_path
      default_config_file_path = 'geminstaller.yml'
      config_file_path ||= default_config_file_path

      # define the service registry
      registry = Needle::Registry.define! do |b|
        # register all services with the builder b
        b.file_reader { GemInstaller::FileReader.new(config_file_path) }
        b.yaml_loader { GemInstaller::YamlLoader.new(b.file_reader.read) }
        b.config { GemInstaller::Config.new(b.yaml_loader.load) }

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