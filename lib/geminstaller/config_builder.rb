dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/requires.rb")

module GemInstaller
  class ConfigBuilder
    attr_writer :file_reader
    attr_writer :yaml_loader
    attr_writer :config_file_path
    
    def build_config
      file_contents = @file_reader.read(@config_file_path)
      yaml = @yaml_loader.load(file_contents)
      config = GemInstaller::Config.new(yaml)
      config
    end
  end
end