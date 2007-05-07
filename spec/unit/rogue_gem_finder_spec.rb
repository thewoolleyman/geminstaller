dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an RogueGemFinder instance with mock dependencies" do
  setup do
    @rogue_gem_finder = GemInstaller::RogueGemFinder.new
    @mock_gem_spec_manager = mock("Mock GemSpecManager")
    @mock_output_proxy = mock("Mock OutputProxy")
    @rogue_gem_finder.gem_spec_manager = @mock_gem_spec_manager
    @rogue_gem_finder.output_proxy = @mock_output_proxy

    @rogue_gem_name = 'rogue'
    @rogue_gem = GemInstaller::RubyGem.new(@rogue_gem_name, :version => '1.0.0')
    @legit_gem = GemInstaller::RubyGem.new('legit', :version => '1.0.0')
  end

  specify "should print rogue gems" do
    @mock_gem_spec_manager.should_receive(:all_local_gems).and_return([@legit_gem, @rogue_gem])
    @mock_gem_spec_manager.should_receive(:local_matching_gems).and_return([])

    valid_yaml = /---.*gems: .- name: rogue.  version: 1.0.0/m
    @mock_output_proxy.should_receive(:sysout).with(valid_yaml)
    
    config_file_paths = []
    output = @rogue_gem_finder.print_rogue_gems([@legit_gem], config_file_paths)
    
    boilerplate = /# .*GemInstaller.*/m
    output.should_match boilerplate
  end

  specify "should print message if gem is a preinstalled gem" do
    @mock_gem_spec_manager.should_receive(:all_local_gems).and_return([@rogue_gem])
    @mock_gem_spec_manager.should_receive(:local_matching_gems).and_return([])

    preinstalled_comment = "# preinstalled comment"
    preinstalled_message_yaml_fragment = /- name: rogue #{preinstalled_comment}/m
    @mock_output_proxy.should_receive(:sysout).with(preinstalled_message_yaml_fragment)
    
    config_file_paths = []
    @rogue_gem_finder.preinstalled_gem_names = [@rogue_gem_name]
    @rogue_gem_finder.preinstalled_comment = preinstalled_comment
    output = @rogue_gem_finder.print_rogue_gems([@legit_gem], config_file_paths)
    
    boilerplate = /# .*GemInstaller.*/m
    output.should_match boilerplate
  end

  specify "should print message if passed an existing config with gems already specified" do
    @mock_gem_spec_manager.should_receive(:all_local_gems).and_return([@rogue_gem])
    @mock_gem_spec_manager.should_receive(:local_matching_gems).and_return([])

    @mock_output_proxy.should_receive(:sysout).with(:anything)

    config_file_paths = ['my_config.yaml']
    output = @rogue_gem_finder.print_rogue_gems([@legit_gem], config_file_paths)
    
    boilerplate = /# .*already specified.*/m
    output.should_match boilerplate
  end

  specify "should print message if passed an existing config with np gems already specified" do
    @mock_gem_spec_manager.should_receive(:all_local_gems).and_return([@rogue_gem])

    @mock_output_proxy.should_receive(:sysout).with(:anything)

    config_file_paths = ['my_config.yaml']
    output = @rogue_gem_finder.print_rogue_gems([], config_file_paths)
    
    boilerplate = /# .*already specified.*/m
    output.should_match boilerplate
  end
end
