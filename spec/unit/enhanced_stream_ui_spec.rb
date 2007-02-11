dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "An EnhancedStreamUI instance" do
  include GemInstaller::SpecUtils
  
  setup do
    # Can't use an rspec mock here, because you can't mock the 'puts' method
    stub_in_stream = StringIO.new("1")
    stub_out_stream = StringIO.new("","w")
    @enhanced_stream_ui = GemInstaller::EnhancedStreamUI.new
  end

  specify "can queue input stream and listen to output stream" do
    input1 = 'input1'
    input2 = 'input2'
    # can pass either a string or an array
    @enhanced_stream_ui.queue_input([input1])
    @enhanced_stream_ui.queue_input(input2)
    question = 'question'
    mock_outs_listener = mock('mock_outs_listener')
    mock_outs_listener.should_receive(:notify).twice.with(question + "  ")
    @enhanced_stream_ui.register_outs_listener([mock_outs_listener])
    @enhanced_stream_ui.ask('question').should==(input1)
    @enhanced_stream_ui.ask('question').should==(input2)
  end

  specify "will throw error if there is no queued input" do
    lambda{ @enhanced_stream_ui.ask('question') }.should_raise(GemInstaller::GemInstallerError)
  end

  specify "can listen to error stream" do
    statement = 'statement'
    mock_errs_listener = mock('mock_errs_listener')
    mock_errs_listener.should_receive(:notify).once.with('ERROR:  ' + statement)
    @enhanced_stream_ui.register_errs_listener([mock_errs_listener])
    @enhanced_stream_ui.alert_error(statement)
  end
end
