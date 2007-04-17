dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an RogueGemFinder instance with mock dependencies" do
  setup do
    @rogue_gem_finder = GemInstaller::RogueGemFinder.new
    @mock_gem_command_manager = mock("Mock GemCommandManager")
    @mock_output_proxy = mock("Mock OutputProxy")
    @rogue_gem_finder.gem_command_manager = @mock_gem_command_manager
    @rogue_gem_finder.gem_spec_manager = @mock_gem_spec_manager
    @rogue_gem_finder.output_proxy = @mock_output_proxy

    @rogue_gem = GemInstaller::RubyGem.new('rogue', :version => '1.0.0')
    @legit_gem = GemInstaller::RubyGem.new('legit', :version => '1.0.0')
  end

  specify "should add a specified gem to the load path" do
    @mock_gem_spec_manager.should_receive(:all_local_gems).and_return([@legit_gem, @rogue_gem])
    @mock_gem_command_manager.should_receive(:local_matching_gem_specs).and_return([])
    
    expected_output = <<-STRING_END
--- 
gems: 
- name: rogue
  version: 1.0.0
STRING_END
    
    @mock_output_proxy.should_receive(:sysout).with(/===.*Rogue Gems.*===/)
    @mock_output_proxy.should_receive(:sysout).with(expected_output)
    @mock_output_proxy.should_receive(:sysout).with(/====================/)
    @rogue_gem_finder.print_rogue_gems([@legit_gem])
  end
end
