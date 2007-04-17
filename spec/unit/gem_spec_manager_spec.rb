dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an GemSpecManager instance with mock dependencies" do
  setup do
    @gem_spec_manager = GemInstaller::GemSpecManager.new
  end

  specify "should return true for gem_matches_spec if platforms match and match_platform = true" do
    spec_matching_sample_gem_platform = Gem::Specification.new
    spec_matching_sample_gem_platform.name = sample_gem.name
    spec_matching_sample_gem_platform.platform = sample_gem.platform
    
    @gem_spec_manager.gem_matches_spec?(sample_gem, spec_matching_sample_gem_platform).should == true
  end
end


