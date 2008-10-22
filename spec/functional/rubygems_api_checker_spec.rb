dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

# This spec is intended to identify breakages caused by changes in the RubyGems API, 
# specifically ones which cause the TestGemHome and EmbeddedGemServer to break,
# which in turn cause all functional tests to break.  This is also an easy place to debug
# said breakages...
describe "RubyGems API" do
  before(:each) do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @gem_runner_proxy = @registry.gem_runner_proxy
  end

  if GemInstaller::RubyGemsVersionChecker.matches?('>=1.1.1')
  # we only care about latest version of RubyGems
  it "should return the expected fixture environment" do
    gem_runner_args = ["env"] + options_for_testing

    output = @gem_runner_proxy.run(gem_runner_args)
    #puts output.join("\n")
    output.join.should match(/GEM PATHS.*test_gem_home/m)
    
  end
  end
end
