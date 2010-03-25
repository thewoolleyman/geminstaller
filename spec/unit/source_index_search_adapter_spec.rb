dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a SourceIndexSearchAdapter instance" do
  before(:each) do
    @source_index_search_adapter = GemInstaller::SourceIndexSearchAdapter.new
    @mock_gem_source_index_proxy = mock("Mock Gem Source Index Proxy")
    @source_index_search_adapter.gem_source_index_proxy = @mock_gem_source_index_proxy
    @sample_gem = sample_gem
  end

  if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
  it "passes gem_pattern regexp and version_requirement for RubyGems <= 0.9.4" do
    @mock_gem_source_index_proxy.should_receive(:refresh!)
    @mock_gem_source_index_proxy.should_receive(:search).with(/^#{@sample_gem.regexp_escaped_name}$/, @sample_gem.version)
    @source_index_search_adapter.search(@sample_gem, @sample_gem.version)
  end

  it "passes empty string pattern and default version when all_local_specs is called for RubyGems <= 0.9.4" do
    @mock_gem_source_index_proxy.should_receive(:refresh!)
    @mock_gem_source_index_proxy.should_receive(:search).with('', GemInstaller::RubyGem.default_version)
    @source_index_search_adapter.all_local_specs
  end
  else
  it "raises a GemInstaller error if Gem::Dependency.new fails" do
    Gem::Dependency.should_receive(:new).and_raise(ArgumentError)
    lambda { @source_index_search_adapter.search(@sample_gem,@sample_gem.version) }.should raise_error(GemInstaller::GemInstallerError)
  end
  end

end

