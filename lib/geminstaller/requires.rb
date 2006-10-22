dir = File.dirname(__FILE__)

# requires for rubygems
require 'rubygems'
require 'rubygems/doc_manager'
require 'rubygems/config_file'
require 'rubygems/cmd_manager'
require 'rubygems/gem_runner'
require 'rubygems/remote_installer'
require 'rubygems/installer'

# third party libs
require 'needle'
require 'yaml'

# internal files
require File.expand_path("#{dir}/application")
require File.expand_path("#{dir}/config")
require File.expand_path("#{dir}/dependency_injector")
require File.expand_path("#{dir}/gem_command_manager")
require File.expand_path("#{dir}/gem_runner_proxy")
require File.expand_path("#{dir}/gem_source_index_proxy")
require File.expand_path("#{dir}/file_reader")
require File.expand_path("#{dir}/yaml_loader")
require File.expand_path("#{dir}/config_builder")
require File.expand_path("#{dir}/ruby_gem")

