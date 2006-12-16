module GemInstaller
  class DependencyInjector
    attr_writer :config_file_paths

    def registry
      @registry ||= create_registry
    end
    
    def default_config_file_path
      'geminstaller.yml'
    end

    private

    def create_registry
      # define properties
      # TODO: no longer using needle, is this still necessary?
      # Note: we have to define a local variable for config_file_path, Needle can't reference the instance variable
      config_file_paths = @config_file_paths
      config_file_paths ||= default_config_file_path

      # define the service registry
      @registry = GemInstaller::Registry.new(config_file_paths)
    end # create_registry
  end
  
  class Registry
    attr_accessor :file_reader, :yaml_loader, :output_proxy, :config_builder, :gem_source_index
    attr_accessor :gem_specifier, :gem_runner, :gem_command_manager, :app

    def initialize(config_file_paths)
      @file_reader = GemInstaller::FileReader.new
      @yaml_loader = GemInstaller::YamlLoader.new
      @output_proxy = GemInstaller::OutputProxy.new
      @arg_parser = GemInstaller::ArgParser.new
  
      @config_builder = GemInstaller::ConfigBuilder.new
      @config_builder.config_file_paths = config_file_paths
      @config_builder.file_reader = @file_reader
      @config_builder.yaml_loader = @yaml_loader
  
      # rubygems classes
      @gem_source_index = Gem::SourceIndex.new
      @gem_source_index_proxy = GemInstaller::GemSourceIndexProxy.new
      @gem_source_index_proxy.gem_source_index = @gem_source_index
  
      @gem_specifier = GemInstaller::GemSpecifier.new
      @gem_specifier.gem_source_index_proxy = @gem_source_index_proxy
  
      @gem_runner = Gem::GemRunner.new
      @gem_runner_proxy = GemInstaller::GemRunnerProxy.new
      @gem_runner_proxy.gem_runner = @gem_runner
  
      @gem_command_manager = GemInstaller::GemCommandManager.new
      @gem_command_manager.gem_source_index_proxy = @gem_source_index_proxy
      @gem_command_manager.gem_runner_proxy = @gem_runner_proxy
      @gem_command_manager
  
      @app = GemInstaller::Application.new
      @app.config_builder = @config_builder
      @app.gem_command_manager = @gem_command_manager
      @app.gem_specifier = @gem_specifier
      @app.output_proxy = @output_proxy
      @app.arg_parser = @arg_parser
      @app.args = ARGV
    end #initialize
  end # Registry class
end