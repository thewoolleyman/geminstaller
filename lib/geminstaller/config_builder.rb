dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/requires.rb")

module GemInstaller
  class ConfigBuilder
    attr_writer :file_reader
    attr_writer :yaml_loader
    attr_writer :config_file_paths
    
    def build_config
      file_contents = @file_reader.read(@config_file_paths)
      file_contents_erb = ERB.new(%{#{file_contents}})
      yaml = @yaml_loader.load(file_contents_erb.result)
      config = GemInstaller::Config.new(yaml)
      config
    end
  end
end