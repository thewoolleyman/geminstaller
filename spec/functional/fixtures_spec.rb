dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "The sample gem fixtures install and uninstall methods" do
  it "should be consistent" do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @gem_command_manager = @registry.gem_command_manager
    @gem_spec_manager = @registry.gem_spec_manager

    # install all the sample gems
    GemInstaller.install(["--silent", "--config=#{dir}/live_geminstaller_config_all_sample_gems.yml"])

    # uninstall all the sample gems
    GemInstaller::TestGemHome.uninstall_all_test_gems
    
    all_local_gems = @gem_spec_manager.all_local_gems

    if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
      # no gems should be left
      test_gems.each do |gem|
        # We must check each sample gem specifically, because on OSX Leopard, user gems end up 
        # being found as well, not just the sample gems in the test gem home.
        @gem_spec_manager.should_not be_is_gem_installed(gem)
      end
    else
      # nothing but sources gem should be left
      all_local_gems.size.should == 1
      all_local_gems[0].name.should == 'sources'
    end
  end

  after(:each) do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end
