dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an application instance invoked with no args" do
  setup do
    application_spec_setup_common
    @mock_arg_parser.should_receive(:parse).with(nil)
    @mock_arg_parser.should_receive(:output).and_return(nil)
  end

  specify "should install a gem which is specified in the config and print startup message" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_install_processor.should_receive(:process).once.with(gems)
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:info,/GemInstaller is verifying gem installation: gemname 1.0/)
    @application.run
  end

  specify "should install multiple gems which are specified in the config and print startup message" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    
    @stub_gem2 = GemInstaller::RubyGem.new("gemname2")
    gems = [@stub_gem, @stub_gem2]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_install_processor.should_receive(:process).once.with(gems)
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:info,/GemInstaller is verifying gem installation: gemname 1.0, gemname2 > 0.0.0/)
    @application.run
  end

  specify "should not install a gem which is already installed" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    
    @stub_gem.check_for_upgrade = false
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_install_processor.should_receive(:process).once.with(gems)
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:info,/GemInstaller is verifying gem installation/)
    @application.run
  end

  specify "should verify and specify gem if check_for_upgrade is specified" do
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    
    @stub_gem.check_for_upgrade = true
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_install_processor.should_receive(:process).once.with(gems)
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:info,/GemInstaller is verifying gem installation/)
    @application.run
  end

  specify "should print any exception message to stderr then exit gracefully" do
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:error,/GemInstaller::GemInstallerError/)
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:error,:anything)
    @mock_config_builder.should_receive(:build_config).and_raise(GemInstaller::GemInstallerError)
    return_code = @application.run
    return_code.should ==(-1)
  end

  specify "should print any exception message AND stacktrace" do
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:error,/GemInstaller::GemInstallerError/)
    @mock_output_filter.should_receive(:geminstaller_output).once() # TODO: how to specify Error/stacktrace exception?
    @mock_config_builder.should_receive(:build_config).and_raise(GemInstaller::GemInstallerError)
    return_code = @application.run
    return_code.should==(-1)
  end
end

context "an application instance invoked with invalid args or help option" do
  setup do
    application_spec_setup_common
  end

  specify "should print any arg parser error output then exit gracefully" do
    arg_parser_output = "arg parser output"
    @mock_output_filter.should_receive(:geminstaller_output).with(:error,/arg parser output/)
    @mock_arg_parser.should_receive(:parse).with(nil).and_return(-1)
    @mock_arg_parser.should_receive(:output).and_return(arg_parser_output)
    return_code = @application.run
    return_code.should==(-1)
  end

  specify "should print any arg parser non-error output then exit gracefully" do
    arg_parser_output = "arg parser output"
    @mock_output_filter.should_receive(:geminstaller_output).with(:info,/arg parser output/)
    @mock_arg_parser.should_receive(:parse).with(nil).and_return(0)
    @mock_arg_parser.should_receive(:output).and_return(arg_parser_output)
    return_code = @application.run
    return_code.should==(0)
  end
end

context "an application instance invoked with one or more missing config files" do
  setup do
    application_spec_setup_common
  end

  specify "should print message and exit gracefully" do
    expected_output = "expected output"
    @mock_output_filter.should_receive(:geminstaller_output).with(:error,/config file is missing/m)
    @mock_output_filter.should_receive(:geminstaller_output).once().with(:error,:anything)
    @mock_arg_parser.should_receive(:parse).with(nil).and_return(0)
    @mock_arg_parser.should_receive(:output).and_return('')
    @mock_config_builder.should_receive(:build_config).and_raise(GemInstaller::MissingFileError)
    return_code = @application.run
    return_code.should==(-1)
  end
end

context "an application instance invoked with alternate config file location" do
  setup do
    application_spec_setup_common
    @mock_output_filter.should_receive(:geminstaller_output).with(:info,:anything)
  end

  specify "should use the alternate config file location" do
    config_paths = 'config_paths'
    @mock_arg_parser.should_receive(:parse).with(nil)
    @options[:config_paths] = config_paths
    @mock_arg_parser.should_receive(:output)
    @mock_config_builder.should_receive(:config_file_paths=).with(config_paths).and_return {@stub_config_local}
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_install_processor.should_receive(:process).once.with(gems)
    @application.run
  end
end

context "an application instance invoked with print-rogue-gems arg" do
  setup do
    application_spec_setup_common
    @mock_arg_parser.should_receive(:parse).with(nil)
    @mock_arg_parser.should_receive(:output).and_return(nil)
    @options[:print_rogue_gems] = true
  end

  specify "should invoke rogue_gem_finder" do
    
    @mock_config_builder.should_receive(:build_config).and_return {@stub_config_local}
    
    gems = [@stub_gem]
    @stub_config.should_receive(:gems).and_return(gems)
    @mock_install_processor.should_receive(:process)
    @mock_output_filter.should_receive(:geminstaller_output).once()
    
    @mock_rogue_gem_finder = mock("Mock RogueGemFinder")
    @mock_rogue_gem_finder.should_receive(:print_rogue_gems).once().with(gems)
    @application.rogue_gem_finder = @mock_rogue_gem_finder
    
    @application.run
  end
end

def application_spec_setup_common
  @mock_arg_parser = mock("Mock Arg Parser")
  @mock_config_builder = mock("Mock Config Builder")
  @stub_config = mock("Mock Config")
  @mock_install_processor = mock("Mock InstallProcessor")
  @mock_output_filter = mock("Mock Output Filter")
  @stub_gem = GemInstaller::RubyGem.new("gemname", :version => "1.0")
  @options = {}

  @stub_config_local = @stub_config

  @application = GemInstaller::Application.new
  @application.options = @options
  @application.arg_parser = @mock_arg_parser
  @application.config_builder = @mock_config_builder
  @application.install_processor = @mock_install_processor
  @application.output_filter = @mock_output_filter
end


