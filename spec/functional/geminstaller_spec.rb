dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

# TOOD: make the local gem server startup automatic, or at least a cleaner warning
# NOTE: this test is dependent upon
# * RubyGems being installed
# * write permissions (or sudo) to gem install dir
context "The geminstaller command line application" do
  include GemInstaller::SpecUtils
  setup do
    # provide an easy flag to skip this test, since it will fail if there is no local gem server available
    @skip_test = skip_gem_server_functional_tests?
    p "WARNING: test is disabled..." if @skip_test    
    p local_gem_server_required_warning
    
    @mock_output_proxy = mock("Mock Output Proxy")
    @registry = GemInstaller::Runner.new.create_registry
    @application = @registry.app
    @application.output_proxy = @mock_output_proxy
  end

  specify "should print usage if given --help arg" do
    args = ["--help"]
    @application.args = args
    @mock_output_proxy.should_receive(:syserr).with(/Usage.*/)
    @application.run
  end
end