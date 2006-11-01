dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "an ArgParser instance with bad args but no trace flag" do
  setup do
    @arg_parser = GemInstaller::ArgParser.new
    @args = ["--badarg"]
  end

  specify "should provide usage in output but no stacktrace" do
    opts = @arg_parser.parse(@args)
    output = @arg_parser.output
    output.should_match(/Usage: .*/)
  end

end

context "an ArgParser instance with bad args and trace flag" do
  setup do
    @args = [] 
  end
  specify "should show an error but no stacktrace" do
  end

end


