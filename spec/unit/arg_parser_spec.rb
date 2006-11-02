dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "an ArgParser instance with bad args" do
  setup do
    common_setup
    @args = ["--badarg"]
  end

  specify "should provide usage in output but no stacktrace" do
    verify_usage_output
  end

end

context "an ArgParser instance with help flag" do
  setup do
    common_setup
    @args = ["-h"] 
  end

  specify "should provide usage in output" do
    verify_usage_output
  end
end

def common_setup
  @arg_parser = GemInstaller::ArgParser.new
end

def verify_usage_output
  opts = @arg_parser.parse(@args)
  output = @arg_parser.output
  output.should_match(/Usage: geminstaller.*/)
end


