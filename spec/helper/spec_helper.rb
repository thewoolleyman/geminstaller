dir = File.dirname(__FILE__)

require File.expand_path("#{dir}/spec_utils.rb")
include GemInstaller::SpecUtils::ClassMethods

$LOAD_PATH.unshift(siterubyver_dir)

require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")
require 'spec'
require 'find' 
require 'stringio'
require File.expand_path("#{dir}/test_gem_home.rb")
require File.expand_path("#{dir}/embedded_gem_server.rb")
if RUBY_PLATFORM.index('mswin')
  require 'win32/process'
  require 'win32/open3'
end


at_exit do
  GemInstaller::EmbeddedGemServer.stop unless $server_was_stopped
  GemInstaller::TestGemHome.reset
end