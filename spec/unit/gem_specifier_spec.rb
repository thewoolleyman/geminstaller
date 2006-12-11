dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a GemSpecifier instance with mock dependencies" do
  include GemInstaller::SpecUtils
  setup do
    @gem_specifier = GemInstaller::GemSpecifier.new
    @mock_gem_source_index_proxy = mock("Mock GemSourceIndexProxy")
    @gem_specifier.gem_source_index_proxy = @mock_gem_source_index_proxy
    
    @sample_gem = sample_gem
    
    @spec_stubgem_100_ruby = Gem::Specification.new do |s|
      s.name = 'stubgem'
      s.version = "1.0.0"
      s.platform = Gem::Platform::RUBY
    end
    @spec_stubgem_multiplatform_101_win32 = Gem::Specification.new do |s|
      s.name = 'stubgem-multiplatform'
      s.version = "1.0.1"
      s.platform = Gem::Platform::WIN32
    end
    @spec_stubgem_multiplatform_101_ruby = Gem::Specification.new do |s|
      s.name = 'stubgem-multiplatform'
      s.version = "1.0.1"
      s.platform = Gem::Platform::RUBY
    end
    @spec_stubgem_multiplatform_100_win32 = Gem::Specification.new do |s|
      s.name = 'stubgem-multiplatform'
      s.version = "1.0.0"
      s.platform = Gem::Platform::WIN32
    end
    @stubgem_specs = [
      @spec_stubgem_100_ruby]
    @stubgem_multiplatform_specs = [
      @spec_stubgem_multiplatform_101_win32, 
      @spec_stubgem_multiplatform_101_ruby, 
      @spec_stubgem_multiplatform_100_win32]
    @mock_gem_source_index_proxy.should_receive(:refresh!).once
  end

  specify "should properly specify default platform if platform is unspecified" do
    @specs = @stubgem_specs
    @sample_gem.platform = nil
    should_specify(@spec_stubgem_100_ruby.name, @spec_stubgem_100_ruby.version, GemInstaller::GemSpecifier.default_platform)
  end

  specify "should properly specify with a binary platform" do
    @specs = @stubgem_multiplatform_specs
    @sample_gem = sample_multiplatform_gem
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "mswin32"
    should_specify()
  end

  specify "should properly specify with a ruby platform even though binary platforms exist" do
    @specs = @stubgem_multiplatform_specs
    @sample_gem = sample_multiplatform_gem
    @sample_gem.name = "stubgem-multiplatform"
    @sample_gem.platform = "ruby"
    should_specify()
  end

  specify "should throw an exception if there are no matches" do
    @specs = []
    should_raise(/Error: No gems matched.*/) { should_specify() }
  end
  
  specify "should throw an exception if there is more than one match" do
    @specs = @stubgem_specs
    spec = @spec_stubgem_100_ruby.clone
    @specs << spec
    should_raise(/Error: More than one gem matched.*/) { should_specify() }
  end
  
  specify "should throw an exception if there is not an exact name match" do
    @specs = @stubgem_specs
    @spec_stubgem_100_ruby.name = 'invalid_name'
    should_raise(/Error: Gem name did not have an exact match.*/) { should_specify() }
  end
  
  def should_specify(name = @sample_gem.name, version = @sample_gem.version, platform = @sample_gem.platform)
    @mock_gem_source_index_proxy.should_receive(:search).once.and_return(@specs)
    @gem_specifier.specify!(@sample_gem)

    platform = GemInstaller::GemSpecifier.default_platform if platform == nil

    @sample_gem.name.should==(name)
    @sample_gem.version.to_s.should==(version.to_s)
    @sample_gem.platform.to_s.should==(platform.to_s)
  end
  
  def should_raise(message_regex, &block)
    error = nil
    lambda {
      begin
        block.call
      rescue GemInstaller::GemInstallerError => error
        raise error
      end
      }.should_raise GemInstaller::GemInstallerError
      error.message.should_match(message_regex)
  end
end