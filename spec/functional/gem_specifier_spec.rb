dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a GemSpecifier instance with a real Gem::SourceIndex dependency" do
  include GemInstaller::SpecUtils
  setup do
    @gem_specifier = GemInstaller::GemSpecifier.new
    gem_source_index_proxy = GemInstaller::GemSourceIndexProxy.new
    gem_source_index_proxy.gem_source_index = Gem::SourceIndex.new
    @gem_specifier.gem_source_index_proxy = gem_source_index_proxy    
    @sample_gem = sample_gem
  end

# TODO: this test fails as part of the suite, because I don't know how to make the sourceindex only go against
#       the embedded gem server - it always searches the actual local gem installation
#  specify "should properly specify default platform if platform is unspecified" do
#    @sample_gem.platform = nil
#    @gem_specifier.specify!(@sample_gem)
#  end

# TODO: this test won't pass, because I don't know how to make the sourceindex only go against
#       the embedded gem server - it always searches the actual local gem installation
#  specify "should properly specify with a binary platform" do
#    @sample_gem.name = "stubgem-multiplatform"
#    @sample_gem.version = "1.0.1"
#    @sample_gem.platform = Gem::Platform::WIN32
#    @gem_specifier.specify!(@sample_gem)
#  end

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

  specify "should throw an exception if there is no match" do
    @sample_gem.name = "stubgem-nomatch"
    expected_error = GemInstaller::GemInstallerError.new
    lambda { @gem_specifier.specify!(@sample_gem) }.should_raise GemInstaller::GemInstallerError
  end
  
  def should_specify(name = @sample_gem.name, version = @sample_gem.version, platform = @sample_gem.platform)
    @gem_specifier.specify!(@sample_gem)

    platform = GemInstaller::GemSpecifier.default_platform if platform == nil

    @sample_gem.name.should ==(name)
    @sample_gem.version.to_s.should ==(version.to_s)
    @sample_gem.platform.to_s.should ==(platform.to_s)
  end
  
end