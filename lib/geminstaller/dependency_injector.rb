dir = File.dirname(__FILE__)
require 'needle'
require File.expand_path("#{dir}/application")
require File.expand_path("#{dir}/config")
require File.expand_path("#{dir}/file_reader")
require File.expand_path("#{dir}/yaml_loader")

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
        b.gem_command_proxy { GemInstaller::GemCommandProxy.new() }

        b.app do
          app = GemInstaller::Application.new
          app.config = b.config
          app.gem_command_proxy = b.gem_command_proxy
          app
        end
      end

      registry.app
    end
  end
end