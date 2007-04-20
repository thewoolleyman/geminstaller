dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/requires.rb")

module GemInstaller
  class ConfigBuilder
    attr_reader :config_file_paths_array
    attr_writer :file_reader
    attr_writer :yaml_loader
    attr_writer :config_file_paths
    
    def self.default_config_file_path
      'geminstaller.yml'
    end

    def build_config
      @config_file_paths ||= GemInstaller::ConfigBuilder.default_config_file_path
      @config_file_paths_array = @config_file_paths.split(",")
      merged_defaults = {}
      merged_gems = {}
      @config_file_paths_array.each do |path|
        file_contents = @file_reader.read(path)
        file_contents_erb = ERB.new(%{#{file_contents}})
        yaml = @yaml_loader.load(file_contents_erb.result)
        merged_defaults.merge!(yaml['defaults']) unless yaml['defaults'].nil?
        next unless yaml['gems']
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