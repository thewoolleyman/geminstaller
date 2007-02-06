dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")

context "spec_utils_spec: the TestGemHome class" do
  include GemInstaller::SpecUtils
  include FileUtils
  specify "should delete and recreate a test gem home" do
    test_gem_home = GemInstaller::SpecUtils::TestGemHome.dir
    working_dir = File.expand_path("#{test_gem_home}/..")
    
    # remove dir if it exists
    FileUtils.rm_rf("#{test_gem_home}")
    # recreate it
    FileUtils.mkdir("#{test_gem_home}")
    # create a dummy dir
    FileUtils.mkdir("#{test_gem_home}/dummydir")
    # make sure dummy dir was created
    entries = Dir.entries("#{test_gem_home}")
    entries.should_include('dummydir')
    
    # init_test_gem_home should delete and recreate dir
    GemInstaller::SpecUtils::TestGemHome.init()
    
    # dummy dir should no longer exist
    entries = Dir.entries("#{test_gem_home}")
    entries.should_not_include('dummydir')
  end
end
