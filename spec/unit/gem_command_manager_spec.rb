dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemCommandManager instance injected with mock dependencies" do
  setup do
    sample_gem_name = "sample-gem"
    install_options = ["--source", "http://gemhost"]
    version = "1.0"
    @sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => version, :install_options => install_options)
    @sample_gem_specification = Gem::Specification.new
    @sample_gem_specification.name = sample_gem_name

    @mock_gem_runner_proxy = mock("Mock GemRunnerProxy")
    @mock_gem_spec_manager = mock("Mock GemSpecManager")
    @mock_gem_interaction_handler = mock("Mock GemDependencyHandler")

    @gem_command_manager = GemInstaller::GemCommandManager.new
    @gem_command_manager.gem_runner_proxy = @mock_gem_runner_proxy
    @gem_command_manager.gem_spec_manager = @mock_gem_spec_manager
    @gem_command_manager.gem_interaction_handler = @mock_gem_interaction_handler
    @escaped_sample_gem_name = @sample_gem.regexp_escaped_name
    
  end

  specify "should be able to install a gem which is not already installed" do
    @mock_gem_spec_manager.should_receive(:local_matching_gem_specs).once.with(@sample_gem).and_return([])
    @mock_gem_runner_proxy.should_receive(:run).once.with(:anything)
    @mock_gem_interaction_handler.should_receive(:dependent_gem=).with(@sample_gem)
    @gem_command_manager.install_gem(@sample_gem)
  end
  
  specify "should not attempt to install a gem which is already installed" do
    error_message = "error message"
    @mock_gem_spec_manager.should_receive(:local_matching_gem_specs).once.with(@sample_gem).and_return([@sample_gem_specification])
    @gem_command_manager.install_gem(@sample_gem)
  end

end
