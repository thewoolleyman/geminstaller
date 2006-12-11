dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a GemSpecifier instance with a real Gem::SourceIndex dependency" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::SpecUtils::EmbeddedGemServer.start
    
    # TODO: refactor this into EmbeddedGemServer when setting up a dummy source dir instead of the real one
    embedded_gem_dir = GemInstaller::SpecUtils::EmbeddedGemServer.embedded_gem_dir
    Gem.use_paths(embedded_gem_dir)
  
    @gem_specifier = GemInstaller::GemSpecifier.new
    gem_source_index_proxy = GemInstaller::GemSourceIndexProxy.new
    gem_source_index_proxy.gem_source_index = Gem::SourceIndex.new
    @gem_specifier.gem_source_index_proxy = gem_source_index_proxy    
    @sample_gem = sample_gem
  end

  specify "should properly specify default platform if platform is unspecified" do
    @sample_gem.platform = nil
    @gem_specifier.specify!(@sample_gem)
  end

  specify "should properly specify with a binary platform" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "1.0.1"
    @sample_gem.platform = Gem::Platform::WIN32
    @gem_specifier.specify!(@sample_gem)
  end

  specify "should properly specify with a ruby platform even though binary platforms exist" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "ruby"
    @gem_specifier.specify!(@sample_gem)
  end

  specify "should properly specify with a non-exact version" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.version = "> 0.0.0"
    @sample_gem.platform = "ruby"
    @gem_specifier.specify!(@sample_gem)
  end
end