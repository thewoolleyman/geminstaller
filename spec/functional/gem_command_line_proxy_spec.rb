dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a gem command line proxy" do
  include GemInstaller::SpecUtils

  setup do
    @gem_command_line_proxy = GemInstaller::GemCommandLineProxy.new
    GemInstaller::SpecUtils::EmbeddedGemServer.start
  end
  
  specify "should return expected remote list output as an array of lines" do
    args = ['list','--remote']
    args += install_options_for_testing
    output = @gem_command_line_proxy.run(args)
    output.should_be_an_instance_of(Array)
    expected_output = [
      "",
      "*** REMOTE GEMS ***",
      "",
      "stubgem (1.0.0)",
      "    Stub gem for testing geminstaller",
      "",
      "stubgem-multiplatform (1.0.1, 1.0.0)",
      "    Multiplatform stub gem for testing geminstaller"]
    output.should==(expected_output)
  end
  
  specify "should raise exception on nonzero return code" do
    args = ['--invalid-option']
    # TODO: patch rspec to accept an exception instance for should_raise expectection parameter
    exception = nil
    begin
      @gem_command_line_proxy.run(args)
    rescue GemInstaller::GemInstallerError => e
      exception = e
    end
    exception.should_be_an_instance_of(GemInstaller::GemInstallerError)
    expected_error_message = "Error: gem command failed.*?ERROR:  Invalid option: --invalid-option.  See 'gem --help'.*"
    exception.message.should_match(/#{expected_error_message}/m)
  end
end
