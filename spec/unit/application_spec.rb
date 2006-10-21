dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "an application instance" do
  setup do
    @mock_config_builder = mock("Mock Config Builder")
    @stub_config = mock("Mock Config")
    @mock_gem_command_manager = mock("Mock GemCommandManager")
    @stub_gem = GemInstaller::RubyGem.new("gemname", :version => "1.0")

    stub_config_local = @stub_config
    @mock_config_builder.should_receive(:build_config).and_return {stub_config_local}

    @application = GemInstaller::Application.new
    @application.config_builder = @mock_config_builder
  end

  specify "should install a gem which is specified in the config" do
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return([gems])
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(false)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@stub_gem)
    @application.run
  end

  specify "should not install a gem which is already installed" do
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return([gems])
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(true)
    @application.run
  end
end


