dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/requires.rb")

module GemInstaller
  class ConfigBuilder
    attr_writer :file_reader
    attr_writer :yaml_loader
    attr_writer :config_file_paths
    
    def build_config
      paths = @config_file_paths.split(",")
      merged_defaults = {}
      merged_gems = {}
      paths.each do |path|
        file_contents = @file_reader.read(path)
        file_contents_erb = ERB.new(%{#{file_contents}})
        yaml = @yaml_loader.load(file_contents_erb.result)
        merged_defaults.merge!(yaml['defaults'])
        yaml['gems'].each do |gem|
          gem_key = [gem['name'],gem['version'],gem['platform']].join('-')
          merged_gems[gem_key] = gem
        end
      end
      merged_yaml = {}
      merged_yaml['defaults'] = merged_defaults
      merged_yaml['gems'] = merged_gems.values
      config = GemInstaller::Config.new(merged_yaml)
      config
    end
  end
end