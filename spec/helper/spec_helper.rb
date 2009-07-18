dir = File.dirname(__FILE__)

require File.expand_path("#{dir}/spec_utils.rb")
include GemInstaller::SpecUtils::ClassMethods

require File.expand_path("#{dir}/test_gem_home.rb")
GemInstaller::TestGemHome.install_rubygems

ALLOW_UNSUPPORTED_RUBYGEMS_VERSION = true

require 'rake'
require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")
require 'pp'
require 'spec'
require 'find' 
require 'stringio'
require File.expand_path("#{dir}/embedded_gem_server.rb")
if RUBY_PLATFORM.index('mswin')
  require 'win32/process'
  require 'win32/open3'
else
  require 'open4'
end
# ruby-debug indirectly requires 'irb', which makes require of 'rdoc/rdoc' in rubygems doc_manager.rb blow up
#require 'ruby-debug'


at_exit do
  GemInstaller::TestGemHome.reset
end