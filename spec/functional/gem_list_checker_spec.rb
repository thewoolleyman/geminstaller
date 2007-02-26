dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemListChecker instance" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
    
    @registry = GemInstaller.create_registry
    @gem_list_checker = @registry.gem_list_checker
    @sample_gem = sample_gem
  end

  specify "should properly specify default platform if platform is unspecified" do
    @sample_gem.platform = nil
    should_not_raise_error    
  end

  specify "should properly specify highest version if version is unspecified" do
    @sample_gem.version = GemInstaller::RubyGem.default_version
    should_not_raise_error    
  end

  specify "should properly specify with a binary platform" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "1.0.1"
    @sample_gem.platform = Gem::Platform::WIN32
    should_not_raise_error    
  end

  specify "should properly specify with a ruby platform even though binary platforms exist" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "ruby"
    should_not_raise_error    
  end

  specify "should properly specify with a non-exact version" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "> 0.0.0"
    @sample_gem.platform = "ruby"
    should_not_raise_error
    @sample_gem.version.should=="1.0.1"
  end
  
  specify "should raise error from verify_and_specify_remote_gem! if there is no match found" do
    @sample_gem.name = "bogusname"
    should_raise_error
  end
  
  def should_raise_error
    lambda { invoke_method }.should_raise(GemInstaller::GemInstallerError)
  end
  
  def should_not_raise_error
    invoke_method
  end
  
  def invoke_method
    @gem_list_checker.verify_and_specify_remote_gem!(@sample_gem)
  end
end