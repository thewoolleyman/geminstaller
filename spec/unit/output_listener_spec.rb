dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an OutputListener" do
  setup do
    @output_listener = GemInstaller::OutputListener.new
    @mock_output_filter = mock("mock output filter")
    @output_listener.output_filter = @mock_output_filter
  end
  
  specify "should queue all output of which it is notified, return it without flushing for read, and flush it upon read!" do
    @output_listener.output_filter = nil
    msg1 = 'msg1'
    msg2 = 'msg2'
    @output_listener.notify(msg1)
    @output_listener.notify(msg2)
    @output_listener.read.should==([msg1, msg2])
    @output_listener.read!.should==([msg1, msg2])
    @output_listener.read!.should==([])
  end
  
  specify "should echo all output, and stop echoing if echo is disabled" do
    echo = "this should be echoed"
    @mock_output_filter.should_receive(:rubygems_output).once.with(:stdout, echo)
    @output_listener.notify(echo)
  end
  
  specify "should call sysout or sysin on based on output_stream property" do
    stdout = "stdout"
    stderr = "stderr"
    @mock_output_filter.should_receive(:rubygems_output).once.with(:stdout, stdout)
    @mock_output_filter.should_receive(:rubygems_output).once.with(:stderr, stderr)
    @output_listener.notify(stdout, :stdout)
    @output_listener.notify(stderr, :stderr)
  end

  specify "should raise error if invalid stream is specified" do
    lambda { @output_listener.notify('foo',:invalid_stream) }.should_raise(GemInstaller::GemInstallerError)
  end
end