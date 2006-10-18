dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/application")
require File.expand_path("#{dir}/../../lib/geminstaller/ruby_gem")

context "an application instance" do
  setup do
    @mock_config = mock("Mock Config")
    @mock_gem_command_manager = mock("Mock GemCommandManager")
    @stub_gem = GemInstaller::RubyGem.new("gemname", :version => "1.0")

    @application = GemInstaller::Application.new
  end

  specify "should install a gem which is specified in the config" do
    @application.config = @mock_config
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @mock_config.should_receive(:gems).once.and_return([gems])
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(false)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@stub_gem)
    @application.run
  end

  specify "should not install a gem which is already installed" do
    @application.config = @mock_config
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @mock_config.should_receive(:gems).once.and_return([gems])
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(true)
    @application.run
  end
end


