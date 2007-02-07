dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "an ArgParser instance with no args" do
  setup do
    common_setup
    @args = []
  end

  specify "should return only verbose with default of false" do
    opts = @arg_parser.parse(@args)
    verbose = opts[:verbose]
    verbose.should==(false)
  end

end

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

context "an ArgParser instance with configs option" do
  setup do
    common_setup
    @config_paths = "c:\geminstaller.yml"
    @args = ["--config=#{@config_paths}"]
  end

  specify "should correctly parse config path from options" do
    opts = @arg_parser.parse(@args)
    config_paths = opts[:config_paths]
    config_paths.should==(@config_paths)
  end
end

context "an ArgParser instance with verbose option" do
  setup do
    common_setup
    @args = ["--verbose"]
  end

  specify "should return verbose flag as true in options hash" do
    opts = @arg_parser.parse(@args)
    opts[:verbose].should==(true)
  end
end

context "an ArgParser instance with quiet option" do
  setup do
    common_setup
    @args = ["--quiet"]
  end

  specify "should return quiet flag as true in options hash" do
    opts = @arg_parser.parse(@args)
    opts[:quiet].should==(true)
  end
end

context "an ArgParser instance with version option" do
  setup do
    common_setup
    @args = ["--version"]
  end

  specify "should return version" do
    opts = @arg_parser.parse(@args)
    output = @arg_parser.output
    output.should==("#{GemInstaller.version}")
  end
end

context "an ArgParser instance with info option" do
  setup do
    common_setup
    @args = ["--info"]
  end

  specify "should return info flag as true in options hash" do
    opts = @arg_parser.parse(@args)
    opts[:info].should==(true)
  end
  
  specify "should expose options as a property after parsing" do
    options = @arg_parser.options
    options.should==(nil)
    @arg_parser.parse(@args)
    options = @arg_parser.options
    options[:info].should==(true)
  end
end

context "an ArgParser instance with sudo option" do
  setup do
    common_setup
    @args = ["--sudo"]
  end

  specify "should return sudo flag as true in options hash" do
    opts = @arg_parser.parse(@args)
    opts[:sudo].should==(true)
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


