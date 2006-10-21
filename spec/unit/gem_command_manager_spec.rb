dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a GemCommandManager instance injected with mock dependencies" do
  setup do
    sample_gem_name = "sample-gem"
    source_param = ["--source", "http://gemhost"]
    version = "1.0"
    @sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => version, :install_options => source_param)

    @mock_gem_runner_proxy = mock("Mock GemRunnerProxy")
    @mock_gem_source_index_proxy = mock("Mock GemSourceIndexProxy")

    @gem_command_manager = GemInstaller::GemCommandManager.new
    @gem_command_manager.gem_runner_proxy = @mock_gem_runner_proxy
    @gem_command_manager.gem_source_index_proxy = @mock_gem_source_index_proxy
  end

  specify "should be able to check for existence of a specific version of a gem" do
    @mock_gem_source_index_proxy.should_receive(:refresh!).once
    @mock_gem_source_index_proxy.should_receive(:search).once.with(/#{@sample_gem.name}$/,@sample_gem.version).and_return([[@sample_gem]])
    @gem_command_manager.is_gem_installed(@sample_gem).should_equal(true)
  end

  specify "should be able to install a gem which is not already installed" do
    @mock_gem_source_index_proxy.should_receive(:refresh!).once
    @mock_gem_source_index_proxy.should_receive(:search).once.with(/#{@sample_gem.name}$/,@sample_gem.version).and_return([[]])
    @mock_gem_runner_proxy.should_receive(:run).once.with(:anything)
    @gem_command_manager.install_gem(@sample_gem)
  end
  
  specify "should not install a gem which is already installed" do
    @mock_gem_source_index_proxy.should_receive(:refresh!).once
    @mock_gem_source_index_proxy.should_receive(:search).once.with(/#{@sample_gem.name}$/,@sample_gem.version).and_return([[@sample_gem]])
    @gem_command_manager.install_gem(@sample_gem)
  end
end
