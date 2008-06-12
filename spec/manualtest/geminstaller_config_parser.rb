require 'rubygems'
require 'geminstaller'

config_file_paths = ARGV[0]
raise "Usage: geminstaller_config_parser <paths_to_geminstaller_config_files>" unless config_file_paths

registry = GemInstaller::Registry.new
config_builder = registry.config_builder
config_builder.config_file_paths = config_file_paths
config = config_builder.build_config
gems = config.gems

gems.each do |gem|
  p "#{gem.name} #{gem.version}"
end
