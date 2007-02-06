dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")

context "spec_utils_spec: the TestGemHome class" do
  include GemInstaller::SpecUtils
  include FileUtils
  setup do
    @test_gem_home = GemInstaller::SpecUtils::TestGemHome.dir
  end
  
  specify "should delete and recreate a test gem home" do
    # remove dir if it exists
    FileUtils.rm_rf("#{@test_gem_home}")
    # recreate it
    FileUtils.mkdir("#{@test_gem_home}")
    # create a dummy dir
    FileUtils.mkdir("#{@test_gem_home}/dummydir")
    # make sure dummy dir was created
    entries = Dir.entries("#{@test_gem_home}")
    entries.should_include('dummydir')
    
    # init_@test_gem_home should delete and recreate dir
    GemInstaller::SpecUtils::TestGemHome.init()
    
    # dummy dir should no longer exist
    entries = Dir.entries("#{@test_gem_home}")
    entries.should_not_include('dummydir')
  end
  
  specify "can use test home dir as RubyGems default home dir, and reset it back to default" do
    # NOTE: This might fail if GEM_HOME is set to a non-standard value - I haven't tried it
    # reset it before the testing
    GemInstaller::SpecUtils::TestGemHome.reset
    # Gem home should equal default dir, but it should not be our test dir
    Gem.dir.should==("#{Gem.default_dir}")
    
    # now, use our test home dir
    GemInstaller::SpecUtils::TestGemHome.use
    # ...and it should now be equal to our test dir
    Gem.dir.should==("#{@test_gem_home}")
    
    # ...and after another reset, it should be back to the original default
    GemInstaller::SpecUtils::TestGemHome.reset
    Gem.dir.should==("#{Gem.default_dir}")
  end
end
