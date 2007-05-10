dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an GemInstallerError" do
  specify "should format a descriptive exit message based on message, command, and args" do
    message = "message"
    command = "command"
    args = ['arg1', 'arg2']
    listener = GemInstaller::OutputListener.new
    listener.notify('msg1')
    listener.notify('msg2')
    error = GemInstaller::GemInstallerError.new
    descriptive_exit_message = error.descriptive_exit_message(message, command, args, listener)
    expected_error_message = /message.*Gem command was:.*command arg1 arg2.*Gem command output was:.*msg1.*msg2/m
    descriptive_exit_message.should match(expected_error_message)
  end
end