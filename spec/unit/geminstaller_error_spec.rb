dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "an GemInstallerError" do
  it "should format a descriptive exit message based on message, command, and args" do
    message = "message"
    command = "command"
    args = ['arg1', 'arg2']
    gem_command_output = ['msg1','msg2']
    error = GemInstaller::GemInstallerError.new
    descriptive_exit_message = error.descriptive_exit_message(message, command, args, gem_command_output)
    expected_error_message = /message.*Gem command was:.*command arg1 arg2.*Gem command output was:.*msg1.*msg2/m
    descriptive_exit_message.should match(expected_error_message)
  end
end