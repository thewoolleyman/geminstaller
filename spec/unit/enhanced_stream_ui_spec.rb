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

  specify "can queue input stream" do
    input = ['input1','input2']
    @enhanced_stream_ui.queue_input(input)
    question = 'question'
    mock_outs_listener = mock('mock_outs_listener')
    mock_outs_listener.should_receive(:notify).twice.with(question + "  ")
    @enhanced_stream_ui.register_outs_listener([mock_outs_listener])
    @enhanced_stream_ui.ask('question').should==(input[0])
    @enhanced_stream_ui.ask('question').should==(input[1])
  end
end
