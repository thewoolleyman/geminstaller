dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")

context "spec_utils_spec: the TestGemDir class" do
  include GemInstaller::SpecUtils
  include FileUtils
  specify "should delete and recreate a test gem dir" do
    test_gem_dir = GemInstaller::SpecUtils::TestGemDir.dir
    working_dir = File.expand_path("#{test_gem_dir}/..")
    
    # remove dir if it exists
    FileUtils.rm_rf("#{test_gem_dir}")
    # recreate it
    FileUtils.mkdir("#{test_gem_dir}")
    # create a dummy dir
    FileUtils.mkdir("#{test_gem_dir}/dummydir")
    # make sure dummy dir was created
    entries = Dir.entries("#{test_gem_dir}")
    entries.should_include('dummydir')
    
    # init_test_gem_dir should delete and recreate dir
    GemInstaller::SpecUtils::TestGemDir.init_test_gem_dir()
    
    # dummy dir should no longer exist
    entries = Dir.entries("#{test_gem_dir}")
    entries.should_not_include('dummydir')
    
  end
end
