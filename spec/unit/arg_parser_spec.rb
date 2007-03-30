dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an ArgParser instance with no args" do
  setup do
    common_setup
  end

  specify "should properly set defaults" do
    @arg_parser.parse(@args)
    @options[:verbose].should==(false)
    @options[:silent].should==(false)
    @options[:info].should==(false)
    @options[:sudo].should==(false)
    @options[:rubygems_output].should==(@rubygems_output_default)
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

context "an ArgParser instance with rubygems-output option" do
  setup do
    common_setup
  end

  specify "should correctly parse rubygems output level from options" do
    @args.push("--rubygems-output","stderr,STDOUT,stderr")
    @arg_parser.parse(@args)
    @options[:rubygems_output].should ==([:stderr,:stdout])
  end

  specify "should correctly parse rubygems output level from options" do
    @args.push("-V","all")
    @arg_parser.parse(@args)
    @options[:rubygems_output].should ==([:all])
  end

  specify "should raise error and not assign options if invalid rubygems-output option is given" do
    invalid = "invalid"
    @args.push("-V",invalid)
    @arg_parser.parse(@args)
    @arg_parser.output.should_match(/Invalid rubygems-output flag: #{invalid}/)
    @options[:rubygems_output].should == @rubygems_output_default
  end
end

context "an ArgParser instance with rubygems-output option and silent option set to true" do
  setup do
    common_setup
  end

  specify "should return error message" do
    @args.push("--silent")
    @args.push("--rubygems-output","stderr,stdout")
    @arg_parser.parse(@args)
    @arg_parser.output.should_match(/The rubygems-output or geminstaller-output option cannot be specified if the silent option is true/)
  end
end

context "an ArgParser instance with silent option" do
  setup do
    common_setup
    @args.push("--silent")
  end

  specify "should return silent flag as true in options hash" do
    @arg_parser.parse(@args)
    @options[:silent].should==(true)
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
  @rubygems_output_default = {}
  @arg_parser.options = @options
end

def verify_usage_output
  @arg_parser.parse(@args)
  output = @arg_parser.output
  output.should_match(/Usage: geminstaller.*/)
end


