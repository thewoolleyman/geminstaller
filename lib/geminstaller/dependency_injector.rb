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
require File.expand_path("#{dir}/gem_command_manager")
require File.expand_path("#{dir}/gem_source_index_proxy")
require File.expand_path("#{dir}/gem_runner_proxy")
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
        b.gem_source_index { Gem::SourceIndex.new }
        b.gem_source_index_proxy do
          gem_source_index_proxy = GemInstaller::GemSourceIndexProxy.new
          gem_source_index_proxy.gem_source_index = b.gem_source_index
          gem_source_index_proxy
        end

        b.gem_runner { Gem::GemRunner.new }
        b.gem_runner_proxy do
          gem_runner_proxy = GemInstaller::GemRunnerProxy.new
          gem_runner_proxy.gem_runner = b.gem_runner
          gem_runner_proxy
        end

        b.gem_command_manager do
          gem_command_manager = GemInstaller::GemCommandManager.new
          gem_command_manager.gem_source_index_proxy = b.gem_source_index_proxy
          gem_command_manager.gem_runner_proxy = b.gem_runner_proxy
          gem_command_manager
        end

        b.app do

          app = GemInstaller::Application.new
          app.config = b.config
          app.gem_command_manager = b.gem_command_manager
          app
        end
      end
      @registry
    end # create_registry
  end
end