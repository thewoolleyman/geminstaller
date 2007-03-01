dir = File.dirname(__FILE__)

# requires for rubygems
require 'rubygems'
require 'rubygems/doc_manager'
require 'rubygems/config_file'
require 'rubygems/cmd_manager'
require 'rubygems/gem_runner'
require 'rubygems/remote_installer'
require 'rubygems/installer'
require 'rubygems/validator'

# third party libs
require 'erb'
require 'optparse'
require 'yaml'
require 'fileutils'
require 'tempfile'

# third party lib extensions
require File.expand_path("#{dir}/rubygems_extensions")

# internal files
require File.expand_path("#{dir}/../geminstaller")
require File.expand_path("#{dir}/application")
require File.expand_path("#{dir}/arg_parser")
require File.expand_path("#{dir}/config")
require File.expand_path("#{dir}/config_builder")
require File.expand_path("#{dir}/dependency_injector")
require File.expand_path("#{dir}/enhanced_stream_ui")
require File.expand_path("#{dir}/file_reader")
require File.expand_path("#{dir}/gem_arg_processor")
require File.expand_path("#{dir}/gem_command_line_proxy")
require File.expand_path("#{dir}/gem_command_manager")
require File.expand_path("#{dir}/gem_dependency_handler")
require File.expand_path("#{dir}/gem_list_checker")
require File.expand_path("#{dir}/gem_runner_proxy")
require File.expand_path("#{dir}/gem_source_index_proxy")
require File.expand_path("#{dir}/geminstaller_error")
require File.expand_path("#{dir}/noninteractive_chooser")
require File.expand_path("#{dir}/output_listener")
require File.expand_path("#{dir}/output_proxy")
require File.expand_path("#{dir}/rubygems_exit")
require File.expand_path("#{dir}/ruby_gem")
require File.expand_path("#{dir}/unexpected_prompt_error")
require File.expand_path("#{dir}/unauthorized_dependency_prompt_error")
require File.expand_path("#{dir}/version_specifier")
require File.expand_path("#{dir}/yaml_loader")

