dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an OutputListener" do
  setup do
    @output_listener = GemInstaller::OutputListener.new
    @mock_output_proxy = mock("mock output proxy")
  end
  
  specify "should queue all output of which it is notified, return it without flushing for read, and flush it upon read!" do
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
    noecho = "this should not be echoed"
    @mock_output_proxy.should_receive(:sysout).once.with(echo)
    @output_listener.output_proxy = @mock_output_proxy
    @output_listener.notify(echo)
    @output_listener.echo = false
    @output_listener.notify(echo)    
  end
  
  specify "should call sysout or sysin on based on output_stream property" do
    stdout = "stdout"
    stderr = "stderr"
    @output_listener.output_proxy = @mock_output_proxy
    @mock_output_proxy.should_receive(:sysout).once.with(stdout)
    @mock_output_proxy.should_receive(:syserr).once.with(stderr)
    @output_listener.notify(stdout, :stdout)
    @output_listener.notify(stderr, :stderr)
  end
end