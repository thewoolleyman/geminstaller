dir = File.dirname(__FILE__)

require File.expand_path("#{dir}/spec_utils.rb")
include GemInstaller::SpecUtils::ClassMethods

$LOAD_PATH.unshift(siterubyver_dir)

require File.expand_path("#{dir}/test_gem_home.rb")
GemInstaller::TestGemHome.install_rubygems
# require 'rubygems'
# ENV['GEM_PATH'] = "#{ENV['GEM_PATH']}:#{File.join(Config::CONFIG['libdir'], 'ruby', 'gems', Config::CONFIG['ruby_version'])}"

require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")
require 'spec'
require 'find' 
require 'stringio'
require File.expand_path("#{dir}/embedded_gem_server.rb")
if RUBY_PLATFORM.index('mswin')
  require 'win32/process'
  require 'win32/open3'
end


at_exit do
  GemInstaller::TestGemHome.reset
end