dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

# NOTE: this test is dependent upon
# * RubyGems being installed
# * write permissions (or sudo) to gem install dir
context "The geminstaller command line application" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::SpecUtils::EmbeddedGemServer.start
    
    @mock_output_proxy = mock("Mock Output Proxy")
    @registry = GemInstaller::create_registry
    @application = @registry.app
    @application.output_proxy = @mock_output_proxy
    
    @gem_command_manager = @registry.gem_command_manager
    @sample_gem = sample_gem
    @gem_command_manager.uninstall_gem(@sample_gem) if @gem_command_manager.is_gem_installed(@sample_gem)
  end

  specify "should print usage if --help arg is specified" do
    @application.args = ["--help"]
    @mock_output_proxy.should_receive(:syserr).with(/Usage.*/)
    @application.run
  end
  
  specify "should install gem if it is not already installed" do
    @application.args = geminstaller_spec_test_args
    @mock_output_proxy.should_receive(:sysout).with(/Installing gem stubgem.*/)
    @application.run
    @gem_command_manager.is_gem_installed(@sample_gem).should==(true)
  end
  
  specify "should print message if gem is already installed and --info arg is specified" do
    @gem_command_manager.install_gem(@sample_gem)
    @application.args = geminstaller_spec_test_args
    @mock_output_proxy.should_receive(:sysout).with(/Gem .* is already installed/)
    @application.run
  end
  
  specify "should print error if --sudo option is specified (it's only supported if geminstaller is invoked via bin/geminstaller, which strips out the option)" do
    @application.args = geminstaller_spec_test_args << '--sudo'
    @mock_output_proxy.should_receive(:syserr).with(/The sudo option is not .* supported/)
    @application.run
  end
  
  specify "should install a platform-specific binary gem" do
    @sample_multiplatform_gem = sample_multiplatform_gem
    @gem_command_manager.uninstall_gem(@sample_multiplatform_gem) if @gem_command_manager.is_gem_installed(@sample_multiplatform_gem)
    @application.args = ["--info","--config=#{dir}/live_geminstaller_config_2.yml"]
    @mock_output_proxy.should_receive(:sysout).with(/Installing gem stubgem-multiplatform.*/)
    @application.run
    @gem_command_manager.is_gem_installed(@sample_multiplatform_gem).should==(true)
  end
  
end

context "The geminstaller command line application created via GemInstaller.run method" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::SpecUtils::EmbeddedGemServer.start
  end

  specify "should run successfully" do
    result = GemInstaller.run(geminstaller_spec_test_args)
    result.should_equal(0)
  end
end

def geminstaller_spec_test_args
  dir = File.dirname(__FILE__)
  ["--info","--verbose","--config=#{dir}/live_geminstaller_config.yml"]
end