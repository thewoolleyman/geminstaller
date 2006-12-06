dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

# TOOD: make the local gem server startup automatic, or at least a cleaner warning
# NOTE: this test is dependent upon
# * RubyGems being installed
# * write permissions (or sudo) to gem install dir
context "The geminstaller command line application" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::SpecUtils::EmbeddedGemServer.start
    
    @mock_output_proxy = mock("Mock Output Proxy")
    @registry = GemInstaller::Runner.new.create_registry
    @application = @registry.app
    @application.output_proxy = @mock_output_proxy
    
    @gem_command_manager = @registry.gem_command_manager
    @sample_gem = sample_gem
    @gem_command_manager.uninstall_gem(@sample_gem)
  end

  specify "should print usage if --help arg is specified" do
    args = ["--help","--config=#{dir}/live_geminstaller_config.yml"]
    @application.args = args
    @mock_output_proxy.should_receive(:syserr).with(/Usage.*/)
    @application.run
  end

  specify "should print message if gem is already installed and --info arg is specified" do
    @gem_command_manager.install_gem(@sample_gem)
    args = ["--info","--config=#{dir}/live_geminstaller_config.yml"]
    @application.args = args
    @mock_output_proxy.should_receive(:sysout).with(/Gem .* is already installed/)
    @application.run
  end
  
end

class MockStderr
  attr_reader :err
  def write
  end
  
  def print(err)
    @err = err
  end
end

context "The geminstaller command line application created via GemInstaller.run method" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::SpecUtils::EmbeddedGemServer.start
    @original_stderr = $stderr
    @mock_stderr = MockStderr.new
    $stderr = @mock_stderr
  end

  specify "should run successfully" do
    GemInstaller.run
    @mock_stderr.err.should_match(/Error:.*/)
  end
  
  teardown do
    $stderr = @original_stderr
  end

end