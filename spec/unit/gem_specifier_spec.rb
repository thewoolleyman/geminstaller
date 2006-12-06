dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a GemSpecifier instance" do
  include GemInstaller::SpecUtils
  setup do
    @gem_specifier = GemInstaller::GemSpecifier.new
    @mock_gem_source_index_proxy = mock("Mock GemSourceIndexProxy")
    @gem_specifier.gem_source_index_proxy = @mock_gem_source_index_proxy
    
    @sample_gem = sample_gem
    
    spec1 = Gem::Specification.new do |s|
      s.name = 'stubgem'
      s.version = "1.0.0"
      s.platform = Gem::Platform::RUBY
    end
    spec2 = Gem::Specification.new do |s|
      s.name = 'stubgem-multiplatform'
      s.version = "1.0.1"
      s.platform = Gem::Platform::WIN32
    end
    spec3 = Gem::Specification.new do |s|
      s.name = 'stubgem-multiplatform'
      s.version = "1.0.1"
      s.platform = Gem::Platform::RUBY
    end
    spec4 = Gem::Specification.new do |s|
      s.name = 'stubgem-multiplatform'
      s.version = "1.0.0"
      s.platform = Gem::Platform::WIN32
    end
    spec5 = Gem::Specification.new do |s|
      s.name = 'stubgem-multiplatform'
      s.version = "1.0.1"
      s.platform = Gem::Platform::RUBY
    end
    @specs = [spec1, spec2, spec3, spec4, spec5]
    
    @mock_gem_source_index_proxy.should_receive(:refresh!).once
    @mock_gem_source_index_proxy.should_receive(:search).once.and_return(@specs)

  end

  specify "should properly specify with an unspecified platform" do
    @sample_gem.platform = nil
    @gem_specifier.specify!(@sample_gem)
  end

  specify "should properly specify with a binary platform" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "mswin32"
    @gem_specifier.specify!(@sample_gem)
  end

  specify "should properly specify with a ruby platform even though binary platforms exist" do
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "ruby"
    @gem_specifier.specify!(@sample_gem)
  end

  # TODO: non-exact versions should be tested with a real SourceIndex object, not a mock
#  specify "should properly specify with a non-exact version" do
#    @sample_gem.name = "stubgem-multiplatform"
#    @sample_gem.version = "> 0.0.0"
#    @sample_gem.platform = "ruby"
#    @gem_specifier.specify!(@sample_gem)
#  end

  specify "should throw an exception if there is no match" do
    @sample_gem.name = "stubgem-nomatch"
    @gem_specifier.specify!(@sample_gem)
  end

  specify "should throw an exception if there is more than one match" do
    spec = Gem::Specification.new do |s|
      s.name = 'stubgem'
      s.version = "1.0.0"
      s.platform = Gem::Platform::RUBY
    end
    @specs << spec
    @gem_specifier.specify!(@sample_gem)
  end
end