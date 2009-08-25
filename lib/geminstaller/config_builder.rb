dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/requires.rb")

module GemInstaller
  class ConfigBuilder
    attr_reader :config_file_paths_array
    attr_writer :file_reader, :yaml_loader, :config_file_paths, :output_filter
    
    def initialize(default_config_file_paths_array = ['geminstaller.yml','config/geminstaller.yml','ci/geminstaller.yml'])
      @default_config_file_paths_array = default_config_file_paths_array
    end
    
    def build_config
      @config_file_paths_array = @config_file_paths ? @config_file_paths.split(",") : @default_config_file_paths_array
      merged_defaults = {}
      merged_gems_in_order = []
      merged_gems_by_key = {}
      file_found = false
      @config_file_paths_array.reverse.each do |path| # reverse because last config files win
        if File.exists?(path)
          file_found = true
        else
          next
        end
        file_contents = @file_reader.read(path)
        next unless file_contents
        next if file_contents.empty?
        expanded_path = File.expand_path(path)
        @output_filter.geminstaller_output(:debug,"Found GemInstaller config file at: #{expanded_path}\n")
        erb = ERB.new(%{#{file_contents}})
        erb_result = nil
        Dir.chdir(File.dirname(expanded_path)) do |yaml_file_dir|
          erb_result = erb.result(include_config_binding)
        end
        yaml = @yaml_loader.load(erb_result)
        merged_defaults.merge!(yaml['defaults']) unless yaml['defaults'].nil?
        next unless yaml['gems']
        yaml['gems'].each do |new_gem|
          gem_key = [new_gem['name'],new_gem['version'],new_gem['platform']].join('-')
          existing_gem = merged_gems_by_key[gem_key]
          unless existing_gem
            merged_gems_in_order << new_gem
            merged_gems_by_key[gem_key] = new_gem
          end
        end
      end
      raise GemInstaller::MissingFileError.new("No config files found at any of these paths: #{@config_file_paths_array.join(', ')}") unless file_found
      merged_yaml = {}
      merged_yaml['defaults'] = merged_defaults
      merged_yaml['gems'] = merged_gems_in_order
      config = GemInstaller::Config.new(merged_yaml)
      config
    end
  
    def include_config_binding
      def include_config(config_file)
        Dir.chdir(File.dirname(config_file)) do |yaml_file_dir|
          erb = File.open(config_file) { |io| ERB.new(io.read) }
          erb.result(include_config_binding)
        end
      end
      binding
    end
  end
end