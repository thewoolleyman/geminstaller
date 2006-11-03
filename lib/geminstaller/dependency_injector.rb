module GemInstaller
  class DependencyInjector
    attr_writer :config_file_path

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
        b.file_reader { GemInstaller::FileReader.new }
        b.yaml_loader { GemInstaller::YamlLoader.new }
        b.output_proxy { GemInstaller::OutputProxy.new }
        b.arg_parser { GemInstaller::ArgParser.new }

        b.config_builder do
          config_builder = GemInstaller::ConfigBuilder.new
          config_builder.config_file_path = config_file_path
          config_builder.file_reader = b.file_reader
          config_builder.yaml_loader = b.yaml_loader
          config_builder
        end

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
          app.config_builder = b.config_builder
          app.gem_command_manager = b.gem_command_manager
          app.output_proxy = b.output_proxy
          app.arg_parser = b.arg_parser
          app
        end
      end
      @registry
    end # create_registry
  end
end