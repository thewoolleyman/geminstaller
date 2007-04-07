dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an RogueGemFinder instance" do
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
    @registry = GemInstaller::create_registry
    @rogue_gem_finder = @registry.rogue_gem_finder
    @gem_command_manager = @registry.gem_command_manager
    @rogue_gem = sample_gem
    @legit_gem = sample_multiplatform_gem
    
    @mock_output_proxy = mock("Mock OutputProxy")
    @rogue_gem_finder.output_proxy = @mock_output_proxy
  end

  specify "should return yaml for all locally installed gems which are not matched by one of gems passed in" do
    @gem_command_manager.install_gem(@rogue_gem)
    @gem_command_manager.install_gem(@legit_gem)

    expected_output = <<-STRING_END
--- 
gems: 
- name: stubgem
  version: 1.0.0
STRING_END

    @mock_output_proxy.should_receive(:sysout).with(expected_output)
    @rogue_gem_finder.print_rogue_gems([@legit_gem])
  end

  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end
