dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an RogueGemFinder instance with mock dependencies" do
  setup do
    @rogue_gem_finder = GemInstaller::RogueGemFinder.new
    @mock_gem_spec_manager = mock("Mock GemSpecManager")
    @mock_output_proxy = mock("Mock OutputProxy")
    @rogue_gem_finder.gem_spec_manager = @mock_gem_spec_manager
    @rogue_gem_finder.output_proxy = @mock_output_proxy

    @rogue_gem = GemInstaller::RubyGem.new('rogue', :version => '1.0.0')
    @legit_gem = GemInstaller::RubyGem.new('legit', :version => '1.0.0')
  end

  specify "should print rogue gems" do
    @mock_gem_spec_manager.should_receive(:all_local_gems).and_return([@legit_gem, @rogue_gem])
    @mock_gem_spec_manager.should_receive(:local_matching_gems).and_return([])

    valid_yaml = /---.*gems: .- name: rogue.  version: 1.0.0/m
    @mock_output_proxy.should_receive(:sysout).with(valid_yaml)
    
    config_file_paths = []
    output = @rogue_gem_finder.print_rogue_gems([@legit_gem], config_file_paths)
    
    boilerplate = /--- .# .*GemInstaller.*/m
    output.should_match boilerplate
  end
end
