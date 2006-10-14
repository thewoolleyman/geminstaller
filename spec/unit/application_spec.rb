dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/application")

context "an application instance" do
  setup do
    @mock_config = mock("Mock Config")
    @mock_gem_command_proxy = mock("Mock GemCommandProxy")
    @stub_gem = mock("Stub Gem")

    @application = GemInstaller::Application.new
  end

  specify "should install a gem which is specified in the config" do
    @application.config = @mock_config
    @application.gem_command_proxy = @mock_gem_command_proxy
    @mock_config.should_receive("gems").once.and_return([@stub_gem])
    @application.run
  end
end


