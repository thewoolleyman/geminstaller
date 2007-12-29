dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "The sample gem fixtures install and uninstall methods" do
  it "should be consistent" do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @gem_command_manager = @registry.gem_command_manager
    @gem_spec_manager = @registry.gem_spec_manager

    # install all the sample gems
    GemInstaller.run(["--silent", "--config=#{dir}/live_geminstaller_config_all_sample_gems.yml"])

    # uninstall all the sample gems
    GemInstaller::TestGemHome.uninstall_all_test_gems
    
    all_local_gems = @gem_spec_manager.all_local_gems

    if RUBYGEMS_VERSION_CHECKER.matches?('>=0.9.5')
      # no gems should be left
      all_local_gems.should be_empty
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
