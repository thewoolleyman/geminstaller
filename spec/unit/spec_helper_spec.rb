dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "the spec_helper" do
  specify "should have code coverage for logic handling non-successful test run" do
    lambda { raise_if_result_not_system_exit(RuntimeError.new) }.should_raise(RuntimeError)
  end
end
