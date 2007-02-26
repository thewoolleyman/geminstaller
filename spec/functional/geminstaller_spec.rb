dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "The geminstaller command line application" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
    
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
  
  specify "should handle 'current' as a valid platform" do
    @application.args = geminstaller_spec_test_args
    @sample_gem.platform = 'current'
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
    @mock_output_proxy.should_receive(:sysout).with(/The sudo option is not .* supported.*/)
    @application.run
  end
  
  specify "should install a platform-specific binary gem" do
    @sample_multiplatform_gem = sample_multiplatform_gem
    @gem_command_manager.uninstall_gem(@sample_multiplatform_gem) if @gem_command_manager.is_gem_installed(@sample_multiplatform_gem)
    @application.args = ["--info","--q","--config=#{dir}/live_geminstaller_config_2.yml"]
    @mock_output_proxy.should_receive(:sysout).with(/Installing gem stubgem-multiplatform.*/)
    @application.run
    @gem_command_manager.is_gem_installed(@sample_multiplatform_gem).should==(true)
  end
  
  specify "should install correctly even if install_options is not specified" do
    @application.args = ["--info","--q","--config=#{dir}/live_geminstaller_config_3.yml"]
    @mock_output_proxy.should_receive(:sysout).with(/Installing gem stubgem.*/)
    @application.run
    @gem_command_manager.is_gem_installed(@sample_gem).should==(true)
  end
  
  specify "should show error if a version specification is not met" do
    @application.args = ["--info","--q","--config=#{dir}/live_geminstaller_config_4.yml"]
    @mock_output_proxy.should_receive(:syserr).with(/The specified version requirement '> 1.0.0' is not met by any of the available versions: 1.0.0./)
    @application.run
    @gem_command_manager.is_gem_installed(@sample_gem).should==(false)
  end
  
end

context "The geminstaller command line application created via GemInstaller.run method" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
  end

  teardown do
    GemInstaller::TestGemHome.reset
  end

  specify "should run successfully" do
    result = GemInstaller.run(geminstaller_spec_test_args)
    result.should_equal(0)
  end
end

def geminstaller_spec_test_args
  dir = File.dirname(__FILE__)
  ["--info","--verbose","--quiet","--config=#{dir}/live_geminstaller_config.yml"]
end