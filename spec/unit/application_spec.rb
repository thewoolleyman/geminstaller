dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "an application instance invoked with no args" do
  setup do
    setup_common
    @mock_arg_parser.should_receive(:parse).with(nil)
    @mock_arg_parser.should_receive(:output).and_return(nil)
  end

  specify "should install a gem which is specified in the config and print startup message" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(false)
    @mock_gem_list_checker.should_receive(:verify_and_specify_remote_gem!).once.with(@stub_gem)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@stub_gem)
    @mock_output_proxy.should_receive(:sysout).once().with(/GemInstaller is verifying gem installation: gemname 1.0/)
    @application.run
  end

  specify "should install multiple gems which are specified in the config and print startup message" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    @stub_gem2 = GemInstaller::RubyGem.new("gemname2")
    gems = [@stub_gem, @stub_gem2]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(false)
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem2).and_return(false)
    @mock_gem_list_checker.should_receive(:verify_and_specify_remote_gem!).once.with(@stub_gem)
    @mock_gem_list_checker.should_receive(:verify_and_specify_remote_gem!).once.with(@stub_gem2)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@stub_gem)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@stub_gem2)
    @mock_output_proxy.should_receive(:sysout).once().with(/GemInstaller is verifying gem installation: gemname 1.0, gemname2 > 0.0.0/)
    @application.run
  end
end

context "an application instance invoked with no args and info, quiet options" do
  setup do
    setup_common
    @mock_arg_parser.should_receive(:parse).with(nil)
    @options[:info] = true
    @options[:quiet] = true
    @mock_arg_parser.should_receive(:output).and_return(nil)
  end

  specify "should show info message for a gem which is already installed if info flag is specified" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    @stub_gem.check_for_upgrade = false
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(true)
    @mock_output_proxy.should_receive(:sysout).once().with(/Gem .*, version .*/)
    @application.run
  end
end

context "an application instance invoked with no args and quiet option" do
  setup do
    setup_common
    @mock_arg_parser.should_receive(:parse).with(nil)
    @options[:quiet] = true
    @mock_arg_parser.should_receive(:output).and_return(nil)
  end

  specify "should not show startup message if quiet flag is specified" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    @stub_gem.check_for_upgrade = false
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(true)
    @application.run
  end

  specify "should not install a gem which is already installed" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    @stub_gem.check_for_upgrade = false
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(true)
    @application.run
  end

  specify "should print any exception message to stderr then exit gracefully" do
    @mock_output_proxy.should_receive(:syserr).once().with(/GemInstaller::GemInstallerError.*/)
    @mock_config_builder.should_receive(:build_config).and_raise(GemInstaller::GemInstallerError)
    return_code = @application.run
    return_code.should==(1)
  end
end

context "an application instance invoked with no args and verbose option" do
  setup do
    setup_common
    @mock_arg_parser.should_receive(:parse).with(nil)
    @options[:verbose] = true
    @mock_arg_parser.should_receive(:output).and_return(nil)
  end

  specify "should print any exception message AND stacktrace if verbose option is specified" do
    @mock_output_proxy.should_receive(:syserr).once().with(/GemInstaller::GemInstallerError/)
    @mock_output_proxy.should_receive(:syserr).once() # TODO: how to specify Error/stacktrace exception?
    @mock_config_builder.should_receive(:build_config).and_raise(GemInstaller::GemInstallerError)
    return_code = @application.run
    return_code.should==(1)
  end
end

context "an application instance invoked with invalid args or help option" do
  setup do
    setup_common
  end

  specify "should print any arg parser output to stderr then exit gracefully" do
    arg_parser_output = "arg parser output"
    @mock_output_proxy.should_receive(:syserr).with(/arg parser output/)
    @mock_arg_parser.should_receive(:parse).with(nil)
    @mock_arg_parser.should_receive(:output).and_return(arg_parser_output)
    return_code = @application.run
    return_code.should==(1)
  end
end

context "an application instance invoked with alternate config file location" do
  setup do
    setup_common
    @mock_output_proxy.should_receive(:sysout).with(:anything)
  end

  specify "should use the alternate config file location" do
    config_paths = 'config_paths'
    @mock_arg_parser.should_receive(:parse).with(nil)
    @options[:config_paths] = config_paths
    @mock_arg_parser.should_receive(:output)
    @mock_config_builder.should_receive(:config_file_paths=).with(config_paths).and_return {@stub_config_local}
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    @application.gem_command_manager = @mock_gem_command_manager
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_gem_command_manager.should_receive(:is_gem_installed).once.with(@stub_gem).and_return(false)
    @mock_gem_list_checker.should_receive(:verify_and_specify_remote_gem!).once.with(@stub_gem)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@stub_gem)
    @application.run
  end
end

def setup_common
  @mock_arg_parser = mock("Mock Arg Parser")
  @mock_config_builder = mock("Mock Config Builder")
  @stub_config = mock("Mock Config")
  @mock_gem_command_manager = mock("Mock GemCommandManager")
  @mock_output_proxy = mock("Mock Output Proxy")
  @mock_gem_list_checker = mock("Mock GemListChecker")
  @stub_gem = GemInstaller::RubyGem.new("gemname", :version => "1.0")

  @stub_config_local = @stub_config

  @options = {}
  @application = GemInstaller::Application.new
  @application.options = @options
  @application.arg_parser = @mock_arg_parser
  @application.config_builder = @mock_config_builder
  @application.gem_list_checker = @mock_gem_list_checker
  @application.output_proxy = @mock_output_proxy
end


