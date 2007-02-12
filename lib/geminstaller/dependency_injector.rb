module GemInstaller
  class DependencyInjector
    def registry
      @registry ||= create_registry
    end
    
    def create_registry
      # define the service registry
      @registry = GemInstaller::Registry.new
    end
  end
  
  class Registry
    attr_accessor :file_reader, :yaml_loader, :output_proxy, :config_builder, :gem_source_index
    attr_accessor :gem_runner, :gem_command_manager, :gem_list_checker, :app, :arg_parser, :options

    def initialize
      @options = {}
      @arg_parser = GemInstaller::ArgParser.new
      @arg_parser.options = @options
      
      @file_reader = GemInstaller::FileReader.new
      @yaml_loader = GemInstaller::YamlLoader.new
      @output_proxy = GemInstaller::OutputProxy.new
      @gem_arg_processor = GemInstaller::GemArgProcessor.new
      @version_specifier = GemInstaller::VersionSpecifier.new
  
      @config_builder = GemInstaller::ConfigBuilder.new
      @config_builder.file_reader = @file_reader
      @config_builder.yaml_loader = @yaml_loader
  
      # rubygems classes
      @gem_source_index = Gem::SourceIndex.new
      @gem_source_index_proxy = GemInstaller::GemSourceIndexProxy.new
      @gem_source_index_proxy.gem_source_index = @gem_source_index
  
      @gem_runner = Gem::GemRunner.new
      @gem_runner_proxy = GemInstaller::GemRunnerProxy.new
      @gem_runner_proxy.gem_runner = @gem_runner
  
      @gem_command_manager = GemInstaller::GemCommandManager.new
      @gem_command_manager.gem_source_index_proxy = @gem_source_index_proxy
      @gem_command_manager.gem_runner_proxy = @gem_runner_proxy
        
      @gem_list_checker = GemInstaller::GemListChecker.new
      @gem_list_checker.gem_command_manager = @gem_command_manager
      @gem_list_checker.gem_arg_processor = @gem_arg_processor
      @gem_list_checker.version_specifier = @version_specifier
  
      @app = GemInstaller::Application.new
      @app.options = @options
      @app.arg_parser = @arg_parser
      @app.config_builder = @config_builder
      @app.gem_command_manager = @gem_command_manager
      @app.gem_list_checker = @gem_list_checker
      @app.output_proxy = @output_proxy
    end
  end
end