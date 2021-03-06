dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "An output filter" do
  before(:each) do
    @output_filter = GemInstaller::OutputFilter.new
    @mock_output_proxy = mock("Mock OutputProxy")
    @output_filter.output_proxy = @mock_output_proxy
    @options = {}
    @output_filter.options = @options
    @message = "message"
    @expected_rubygems_stdout_message = "[RubyGems:stdout] #{@message}"
    @expected_rubygems_stderr_message = "[RubyGems:stderr] #{@message}"
  end

  it "should pass formatted rubygems stdout message to output proxy if 'stdout' rubygems_output option is set" do
    @options[:rubygems_output] = [:stdout]
    @mock_output_proxy.should_receive(:sysout).with(@expected_rubygems_stdout_message)
    @output_filter.rubygems_output(:stdout, @message)
  end

  it "should pass formatted rubygems stdout and stderr message to output proxy if 'all' rubygems_output option is set" do
    @options[:rubygems_output] = [:all]
    @mock_output_proxy.should_receive(:sysout).with(@expected_rubygems_stdout_message)
    @mock_output_proxy.should_receive(:sysout).with(@expected_rubygems_stderr_message)
    @output_filter.rubygems_output(:stdout, @message)
    @output_filter.rubygems_output(:stderr, @message)
  end

  it "should not pass rubygems stdout message to output proxy if 'stdout' rubygems_output option is not set" do
    @options[:rubygems_output] = [:stderr]
    @output_filter.rubygems_output(:stdout, @message)
  end

  it "should not pass any message to output proxy if 'silent' option is set" do
    @options[:silent] = true
    @output_filter.rubygems_output(:stdout, @message)
    @output_filter.rubygems_output(:stderr, @message)
  end

  it "should pass geminstaller info message to output proxy if 'info' geminstaller_output option is set" do
    @options[:geminstaller_output] = [:info]
    @mock_output_proxy.should_receive(:sysout).with(@message)
    @output_filter.geminstaller_output(:info, @message)
  end

  it "should use error stream if geminstaller output type is error" do
    @options[:geminstaller_output] = [:error]
    @mock_output_proxy.should_receive(:syserr).with(@message)
    @output_filter.geminstaller_output(:error, @message)
  end


end