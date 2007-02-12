dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "an ArgParser instance with no args" do
  setup do
    common_setup
  end

  specify "should properly set defaults" do
    @arg_parser.parse(@args)
    @options[:verbose].should==(false)
    @options[:quiet].should==(false)
    @options[:info].should==(false)
    @options[:sudo].should==(false)
  end

end

context "an ArgParser instance with bad args" do
  setup do
    common_setup
    @args.push("--badarg")
  end

  specify "should provide usage in output but no stacktrace" do
    verify_usage_output
  end
end

context "an ArgParser instance with args which are not nil and are not passed as an array" do
  setup do
    common_setup
    @args = 'not an array'
  end

  specify "should raise exception" do
    lambda { @arg_parser.parse(@args) }.should_raise(GemInstaller::GemInstallerError)
  end
end

context "an ArgParser instance with help flag" do
  setup do
    common_setup
    @args.push("-h")
  end

  specify "should provide usage in output" do
    verify_usage_output
  end
end

context "an ArgParser instance with configs option" do
  setup do
    common_setup
    @config_paths = "c:\geminstaller.yml"
    @args.push("--config=#{@config_paths}")
  end

  specify "should correctly parse config path from options" do
    @arg_parser.parse(@args)
    config_paths = @options[:config_paths]
    config_paths.should==(@config_paths)
  end
end

context "an ArgParser instance with verbose option" do
  setup do
    common_setup
    @args.push("--verbose")
  end

  specify "should return verbose flag as true in options hash" do
    @arg_parser.parse(@args)
    @options[:verbose].should==(true)
  end
end

context "an ArgParser instance with quiet option" do
  setup do
    common_setup
    @args.push("--quiet")
  end

  specify "should return quiet flag as true in options hash" do
    @arg_parser.parse(@args)
    @options[:quiet].should==(true)
  end
end

context "an ArgParser instance with version option" do
  setup do
    common_setup
    @args.push("--version")
  end

  specify "should return version" do
    @arg_parser.parse(@args)
    output = @arg_parser.output
    output.should==("#{GemInstaller.version}")
  end
end

context "an ArgParser instance with info option" do
  setup do
    common_setup
    @args.push("--info")
  end

  specify "should return info flag as true in options hash" do
    @arg_parser.parse(@args)
    @options[:info].should==(true)
  end
end

context "an ArgParser instance with sudo option" do
  setup do
    common_setup
    @args.push("--sudo")
  end

  specify "should return error message (sudo is not yet supported when GemInstaller is invoked programatically)" do
    @arg_parser.parse(@args)
    @arg_parser.output.should_match(/The sudo option is not .* supported.*/)
  end
end

def common_setup
  @arg_parser = GemInstaller::ArgParser.new
  @args = []
  @options = {}
  @arg_parser.options = @options
end

def verify_usage_output
  @arg_parser.parse(@args)
  output = @arg_parser.output
  output.should_match(/Usage: geminstaller.*/)
end


