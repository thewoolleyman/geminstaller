dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "an application instance invoked with no args" do
  setup do
    setup_common
    @mock_arg_parser.should_receive(:parse).and_return([])
    @mock_arg_parser.should_receive(:output).and_return(nil)
  end

  specify "should install a gem which is specified in the config" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return([gems])
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(false)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@stub_gem)
    @application.run
  end

  specify "should not install a gem which is already installed" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return([gems])
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(true)
    @application.run
  end

  specify "should print any exception message to stderr then exit gracefully" do
    setup_mock_output_proxy
    @mock_output_proxy.should_receive(:syserr).with("RuntimeError")
    @mock_config_builder.should_receive(:build_config).and_raise(RuntimeError)
    return_code = @application.run
    return_code.should_equal(1)
  end

end

context "an application instance invoked with invalid args or help option" do
  setup do
    setup_common
  end

  specify "should print any arg parser output to stderr then exit gracefully" do
    setup_mock_output_proxy
    arg_parser_output = "arg parser output"
    @mock_output_proxy.should_receive(:syserr).with(arg_parser_output)
    @mock_arg_parser.should_receive(:parse).and_return([])
    @mock_arg_parser.should_receive(:output).and_return(arg_parser_output)
    return_code = @application.run
    return_code.should_equal(1)
  end

end

def setup_common
  @mock_arg_parser = mock("Mock Arg Parser")
  @mock_config_builder = mock("Mock Config Builder")
  @stub_config = mock("Mock Config")
  @mock_gem_command_manager = mock("Mock GemCommandManager")
  @stub_gem = GemInstaller::RubyGem.new("gemname", :version => "1.0")

  @stub_config_local = @stub_config

  @application = GemInstaller::Application.new
  @application.arg_parser = @mock_arg_parser
  @application.config_builder = @mock_config_builder
end

def setup_mock_output_proxy
  @mock_output_proxy = mock("Mock Output Proxy")
  @application.output_proxy = @mock_output_proxy
end


