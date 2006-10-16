dir = File.dirname(__FILE__)

# requires for rubygems
require 'rubygems'
require 'rubygems/doc_manager'
require 'rubygems/config_file'
require 'rubygems/cmd_manager'
require 'rubygems/gem_runner'
require 'rubygems/remote_installer'
require 'rubygems/installer'

require 'needle'
require File.expand_path("#{dir}/application")
require File.expand_path("#{dir}/config")
require File.expand_path("#{dir}/gem_command_proxy")
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

    def registry
      @registry ||= create_registry
    end

    private

    def create_registry
      # define properties
      # Note: we have to define a local variable for config_file_path, Needle can't reference the instance variable
      config_file_path = @config_file_path
      default_config_file_path = 'geminstaller.yml'
      config_file_path ||= default_config_file_path

      # define the service registry
      @registry = Needle::Registry.define! do |b|
        # register all services with the builder b
        b.file_reader { GemInstaller::FileReader.new(config_file_path) }
        b.yaml_loader { GemInstaller::YamlLoader.new(b.file_reader.read) }
        b.config { GemInstaller::Config.new(b.yaml_loader.load) }

        # rubygems classes
        b.gem_cache { Gem::Cache.new }
        b.gem_runner { Gem::GemRunner.new }

        b.gem_command_proxy do
          gem_command_proxy = GemInstaller::GemCommandProxy.new()
          gem_command_proxy.gem_cache = b.gem_cache
          gem_command_proxy.gem_runner = b.gem_runner
          gem_command_proxy
        end

        b.app do

          app = GemInstaller::Application.new
          app.config = b.config
          app.gem_command_proxy = b.gem_command_proxy
          app
        end
      end
      @registry
    end # create_registry
  end
end