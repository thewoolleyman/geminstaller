# Project-specific configuration for CruiseControl.rb
require 'fileutils'

Project.configure do |project|
  project.email_notifier.emails = ['thewoolleyman@gmail.com']
  require "#{File.dirname(__FILE__)}/vendor/plugins/pivotal_core_bundle/lib/cruise/pivotal_cruise_config.rb"
  if project.name =~ /rubygems[_-](.*)$/ # geminstaller_using_rubygems_0-9-4
    rubygems_version = $1
    rubygems_version.gsub!('-','.')
    ENV['RUBYGEMS_VERSION'] = rubygems_version
  end
end
