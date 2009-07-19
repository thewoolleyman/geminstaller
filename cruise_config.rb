# Project-specific configuration for CruiseControl.rb
require 'fileutils'
require 'socket'

Project.configure do |project|
  triggers = []
  if File.exists?(File.expand_path(File.dirname(project.path)) + '/../../RubyGems')
    triggers << :RubyGems
  end
  if File.exists?(File.expand_path(File.dirname(project.path)) + '/../../dummyrepo')
    triggers << :dummyrepo
  end
  project.triggered_by *triggers
  project.email_notifier.emails = ['thewoolleyman@gmail.com'] if Socket.gethostname =~ /(thewoolleyweb.com|ci.pivotallabs.com)/ 
  if project.name =~ /rubygems[_-](.*)$/ # geminstaller_using_rubygems_0-9-4
    rubygems_version = $1
    rubygems_version.gsub!('-','.')
    ENV['RUBYGEMS_VERSION'] = rubygems_version
  end
  if project.name =~ /smoketest/i # smoketest project
    project.rake_task = project.name
  end
end
