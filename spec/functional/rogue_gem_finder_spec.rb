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
    @legit_gem = sample_dependent_multiplatform_gem
    @legit_gem.install_options << "--include-dependencies"
    
    @mock_output_proxy = mock("Mock OutputProxy")
    @rogue_gem_finder.output_proxy = @mock_output_proxy
  end

  specify "should return yaml for all locally installed gems which are not matched by one of the config gems passed in" do
    @gem_command_manager.install_gem(@rogue_gem)
    # legit gem will also install a dependency, which should be detected as a valid gem in the config,
    # since it's parent is in the config
    @gem_command_manager.install_gem(@legit_gem)

    @mock_output_proxy.should_receive(:sysout)
    
    config_file_paths = []
    
    output = @rogue_gem_finder.print_rogue_gems([@legit_gem], config_file_paths)
    
    output.should match(/#{@rogue_gem.name}/)
  end

  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end
