# Project-specific configuration for CruiseControl.rb
require 'fileutils'

Project.configure do |project|
  if File.exists?(File.expand_path(File.dirname(project.path)) + '/../../RubyGems')
    project.triggered_by :RubyGems
  end
  if File.exists?(File.expand_path(File.dirname(project.path)) + '/../../dummyrepo')
    project.triggered_by :dummyrepo
  end
  project.email_notifier.emails = ['thewoolleyman@gmail.com']
  if project.name =~ /rubygems[_-](.*)$/ # geminstaller_using_rubygems_0-9-4
    rubygems_version = $1
    rubygems_version.gsub!('-','.')
    ENV['RUBYGEMS_VERSION'] = rubygems_version
  end
  if project.name =~ /smoketest/i # smoketest project
    project.rake_task = project.name
  end
end
