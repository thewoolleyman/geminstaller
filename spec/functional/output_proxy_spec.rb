dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "The output proxy" do
  setup do
    @output_proxy = GemInstaller::OutputProxy.new
    @original_stdout = $stdout
    @mock_stdout = MockStdout.new
    $stdout = @mock_stdout
    @original_stderr = $stderr
    @mock_stderr = MockStderr.new
    $stderr = @mock_stderr
    @options = {}
    @output_proxy.options = @options
  end

  specify "should proxy to stdout and stderr" do
    sysout = "out!"
    syserr = "err!"
    @output_proxy.sysout(sysout)
    @output_proxy.syserr(syserr)
    @mock_stdout.out.should==(sysout)
    @mock_stderr.err.should==(syserr)
  end
  
  specify "should support option to redirect stderr to stdout" do
    syserr = "err!"
    @options[:redirect_stderr_to_stdout] = true
    @output_proxy.syserr(syserr)
    @mock_stdout.out.should==(syserr)
    @mock_stderr.err.should==(nil)
  end
  
  specify "should allow default output stream to be set for output method" do
    sysout = "out!"
    syserr = "err!"
    @output_proxy.default_stream = :stdout
    @output_proxy.output(sysout)
    @mock_stdout.out.should==(sysout)
    @output_proxy.default_stream = :stderr
    @output_proxy.output(syserr)
    @mock_stderr.err.should==(syserr)    
  end
  
  teardown do
    $stdout = @original_stdout
    $stderr = @original_stderr
  end

end