dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

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

  specify "will throw unexpected prompt error if there is no queued input" do
    lambda{ @enhanced_stream_ui.ask('question') }.should_raise(GemInstaller::UnexpectedPromptError)
  end

  specify "will force throw of GemInstaller::UnauthorizedDependencyPromptError or RubyGemsExit if intercepted by alert_error" do
    begin
      raise GemInstaller::UnauthorizedDependencyPromptError.new
    rescue StandardError => error
      lambda{ @enhanced_stream_ui.alert_error('statement') }.should_raise(GemInstaller::UnauthorizedDependencyPromptError)
    end

    begin
      raise GemInstaller::RubyGemsExit.new
    rescue StandardError => error
      lambda{ @enhanced_stream_ui.alert_error('statement') }.should_raise(GemInstaller::RubyGemsExit)
    end
  end

  specify "can listen to error stream" do
    statement = 'statement'
    mock_errs_listener = mock('mock_errs_listener')
    mock_errs_listener.should_receive(:notify).once.with('ERROR:  ' + statement)
    @enhanced_stream_ui.register_errs_listener([mock_errs_listener])
    @enhanced_stream_ui.alert_error(statement)
  end
  
  specify "will stop listening to streams if listeners are unregistered" do
    statement = 'statement'
    mock_errs_listener = mock('mock_errs_listener')
    mock_outs_listener = mock('mock_outs_listener')
    mock_errs_listener.should_receive(:notify).once.with('ERROR:  ' + statement)
    mock_outs_listener.should_receive(:notify).once.with(statement)
    # listeners should receive messages when they are registered
    @enhanced_stream_ui.register_errs_listener([mock_errs_listener])
    @enhanced_stream_ui.register_outs_listener([mock_outs_listener])
    @enhanced_stream_ui.alert_error(statement)
    @enhanced_stream_ui.say(statement)

    # listeners should no longer receive messages when they are unregistered
    @enhanced_stream_ui.unregister_errs_listener(mock_errs_listener)
    @enhanced_stream_ui.unregister_outs_listener(mock_outs_listener)
    @enhanced_stream_ui.alert_error(statement)
    @enhanced_stream_ui.say(statement)
    
  end
  
  specify "will raise exception on terminate_interaction! (instead of exiting)" do
    lambda{ @enhanced_stream_ui.terminate_interaction!(0) }.should_raise(GemInstaller::GemInstallerError)
  end

  specify "will raise RubyGemsExit on terminate_interaction and status == 0 (instead of exiting)" do
    lambda{ @enhanced_stream_ui.terminate_interaction(0) }.should_raise(GemInstaller::RubyGemsExit)
  end

  specify "will raise exception on terminate_interaction and status != 0 (instead of exiting)" do
    lambda{ @enhanced_stream_ui.terminate_interaction(1) }.should_raise(GemInstaller::GemInstallerError)
  end
  
  specify "will call gem_interaction_handler when ask_yes_no is called" do
    mock_gem_interaction_handler = mock("mock_gem_interaction_handler")
    @enhanced_stream_ui.gem_interaction_handler = mock_gem_interaction_handler
    question = 'question'
    error = GemInstaller::UnauthorizedDependencyPromptError
    mock_gem_interaction_handler.should_receive(:handle_prompt).with(question).and_raise(error)
    lambda{ @enhanced_stream_ui.ask_yes_no(question) }.should_raise(error)
  end

  
end
