dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a GemListChecker instance" do
  before(:each) do
    GemInstaller::TestGemHome.use
    
    @registry = GemInstaller.create_registry
    @gem_list_checker = @registry.gem_list_checker
    @sample_gem = sample_gem
  end

  it "should properly specify default platform if platform is unspecified" do
    @sample_gem.platform = nil
    should_not_raise_error    
  end

  it "should properly specify highest version if version is unspecified" do
    @sample_gem.version = GemInstaller::RubyGem.default_version
    should_not_raise_error    
  end

  it "should properly specify with a binary platform" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "1.0.1"
    if RUBYGEMS_VERSION_CHECKER.matches?('>=0.9.5')
      @sample_gem.platform = Gem::Platform.new('mswin32')
    else
      @sample_gem.platform = Gem::Platform::WIN32
    end
    should_not_raise_error    
  end

  it "should properly specify with a ruby platform even though binary platforms exist" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "ruby"
    should_not_raise_error    
  end

  it "should properly specify with a non-exact version" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "> 0.0.0"
    @sample_gem.platform = "ruby"
    should_not_raise_error
    @sample_gem.version.should=="1.0.1"
  end
  
  it "should raise error from verify_and_specify_remote_gem! if there is no match found" do
    @sample_gem.name = "bogusname"
    should raise_error
  end
  
  after(:each) do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end

  def should raise_error
    lambda { invoke_method }.should raise_error(GemInstaller::GemInstallerError)
  end
  
  def should_not_raise_error
    invoke_method
  end
  
  def invoke_method
    @gem_list_checker.verify_and_specify_remote_gem!(@sample_gem)
  end
end