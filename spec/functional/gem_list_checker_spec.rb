dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a GemListChecker instance" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::SpecUtils::EmbeddedGemServer.start
    
    # TODO: refactor this into EmbeddedGemServer when setting up a dummy source dir instead of the real one
    embedded_gem_dir = GemInstaller::SpecUtils::EmbeddedGemServer.embedded_gem_dir
    Gem.use_paths(embedded_gem_dir)
  
    @registry = GemInstaller::Runner.new.create_registry
    @gem_list_checker = @registry.gem_list_checker
    @sample_gem = sample_gem
  end

  specify "should properly specify default platform if platform is unspecified" do
    @sample_gem.platform = nil
    should_return_true_from_check    
  end

  specify "should properly specify with a binary platform" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "1.0.1"
    @sample_gem.platform = Gem::Platform::WIN32
    should_return_true_from_check    
  end

  specify "should properly specify with a ruby platform even though binary platforms exist" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "ruby"
    should_return_true_from_check    
  end

  specify "should properly specify with a non-exact version" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "> 0.0.0"
    @sample_gem.platform = "ruby"
    should_return_true_from_check    
  end
  
  def should_return_true_from_check
    @gem_list_checker.gem_exists_remotely?(@sample_gem).should==(true)
  end
end