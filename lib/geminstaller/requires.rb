dir = File.dirname(__FILE__)

# require for rubygems package
require 'rubygems'

# backward compability and version-checking stuff - must be required before it is used
require 'rubygems/rubygems_version'
require File.expand_path("#{dir}/rubygems_version_checker")

# requires for rubygems internal classes
require 'rubygems/doc_manager'
require 'rubygems/config_file'
if RUBYGEMS_VERSION_CHECKER.matches?('<0.9.3')
  require 'rubygems/cmd_manager'
else
  require 'rubygems/command_manager'
end
require 'rubygems/gem_runner'
require 'rubygems/remote_installer'
require 'rubygems/installer'
require 'rubygems/validator'

# these are order-dependent.  Any better way???
unless RUBYGEMS_VERSION_CHECKER.matches?('<0.9.3')
  require 'rubygems/commands/query_command'
  require 'rubygems/commands/list_command'
end

# backward compability support for prior rubygems versions 
require File.expand_path("#{dir}/backward_compatibility")

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
require File.expand_path("#{dir}/autogem")
require File.expand_path("#{dir}/config")
require File.expand_path("#{dir}/config_builder")
require File.expand_path("#{dir}/dependency_injector")
require File.expand_path("#{dir}/enhanced_stream_ui")
require File.expand_path("#{dir}/exact_match_list_command")
require File.expand_path("#{dir}/file_reader")
require File.expand_path("#{dir}/gem_arg_processor")
require File.expand_path("#{dir}/gem_command_manager")
require File.expand_path("#{dir}/gem_interaction_handler")
require File.expand_path("#{dir}/gem_list_checker")
require File.expand_path("#{dir}/gem_runner_proxy")
require File.expand_path("#{dir}/gem_source_index_proxy")
require File.expand_path("#{dir}/gem_spec_manager")
require File.expand_path("#{dir}/geminstaller_error")
require File.expand_path("#{dir}/geminstaller_access_error")
require File.expand_path("#{dir}/install_processor")
require File.expand_path("#{dir}/missing_dependency_finder")
require File.expand_path("#{dir}/missing_file_error")
require File.expand_path("#{dir}/noninteractive_chooser")
require File.expand_path("#{dir}/output_filter")
require File.expand_path("#{dir}/output_listener")
require File.expand_path("#{dir}/output_observer")
require File.expand_path("#{dir}/output_proxy")
require File.expand_path("#{dir}/rogue_gem_finder")
require File.expand_path("#{dir}/rubygems_exit")
require File.expand_path("#{dir}/ruby_gem")
require File.expand_path("#{dir}/unexpected_prompt_error")
require File.expand_path("#{dir}/unauthorized_dependency_prompt_error")
require File.expand_path("#{dir}/valid_platform_selector")
require File.expand_path("#{dir}/version_specifier")
require File.expand_path("#{dir}/yaml_loader")

