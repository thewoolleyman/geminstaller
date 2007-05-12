dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "an ArgParser instance with no args" do
  before(:each) do
    common_setup
  end

  it "should properly set defaults" do
    @arg_parser.parse(@args)
    @options[:silent].should==(false)
    @options[:sudo].should==(false)
    @options[:geminstaller_output].should==(@geminstaller_output_default)
    @options[:rubygems_output].should==(@rubygems_output_default)
  end

end

describe "an ArgParser instance with bad args" do
  before(:each) do
    common_setup
    @args.push("--badarg")
  end

  it "should provide usage in output but no stacktrace" do
    verify_usage_output
  end
end

describe "an ArgParser instance with args which are not nil and are not passed as an array" do
  before(:each) do
    common_setup
    @args = 'not an array'
  end

  it "should raise exception" do
    lambda { @arg_parser.parse(@args) }.should raise_error(GemInstaller::GemInstallerError)
  end
end

describe "an ArgParser instance with help flag" do
  before(:each) do
    common_setup
    @args.push("-h")
  end

  it "should provide usage in output" do
    verify_usage_output
  end
end

describe "an ArgParser instance with configs option" do
  before(:each) do
    common_setup
    @config_paths = "c:\geminstaller.yml"
    @args.push("--config=#{@config_paths}")
  end

  it "should correctly parse config path from options" do
    @arg_parser.parse(@args)
    config_paths = @options[:config_paths]
    config_paths.should==(@config_paths)
  end
end

describe "an ArgParser instance with geminstaller-output option" do
  before(:each) do
    common_setup
  end

  it "should correctly parse geminstaller output level from options" do
    @args.push("--geminstaller-output","error,install,info,commandecho,debug")
    @arg_parser.parse(@args)
    [:error,:install,:info,:commandecho,:debug].each do |option|
      @options[:geminstaller_output].should include(option)
    end
  end

  it "should correctly parse geminstaller output level from options" do
    @args.push("-g","all")
    @arg_parser.parse(@args)
    @options[:geminstaller_output].should ==([:all])
  end

  it "should raise error and not assign options if invalid geminstaller-output option is given" do
    invalid = "invalid"
    @args.push("-g",invalid)
    @arg_parser.parse(@args)
    @arg_parser.output.should match(/Invalid geminstaller-output flag: #{invalid}/)
    @options[:geminstaller_output].should == @geminstaller_output_default
  end
end

describe "an ArgParser instance with rubygems-output option" do
  before(:each) do
    common_setup
  end

  it "should correctly parse rubygems output level from options" do
    @args.push("--rubygems-output","stderr,STDOUT,stderr")
    @arg_parser.parse(@args)
    @options[:rubygems_output].should ==([:stderr,:stdout])
  end

  it "should correctly parse rubygems output level from options" do
    @args.push("-r","all")
    @arg_parser.parse(@args)
    @options[:rubygems_output].should ==([:all])
  end

  it "should raise error and not assign options if invalid rubygems-output option is given" do
    invalid = "invalid"
    @args.push("-r",invalid)
    @arg_parser.parse(@args)
    @arg_parser.output.should match(/Invalid rubygems-output flag: #{invalid}/)
    @options[:rubygems_output].should == @rubygems_output_default
  end
end

describe "an ArgParser instance with rubygems-output option and silent option set to true" do
  before(:each) do
    common_setup
  end

  it "should return error message" do
    @args.push("--silent")
    @args.push("--rubygems-output","stderr,stdout")
    @arg_parser.parse(@args)
    @arg_parser.output.should match(/The rubygems-output or geminstaller-output option cannot be specified if the silent option is true/)
  end
end

describe "an ArgParser instance with silent option" do
  before(:each) do
    common_setup
    @args.push("--silent")
  end

  it "should return silent flag as true in options hash" do
    @arg_parser.parse(@args)
    @options[:silent].should==(true)
  end
end

describe "an ArgParser instance with exceptions option" do
  before(:each) do
    common_setup
    @args.push("--exceptions")
  end

  it "should return exceptions flag as true in options hash" do
    @arg_parser.parse(@args)
    @options[:exceptions].should==(true)
  end
end

describe "an ArgParser instance with redirect-stderr-to-stdout option" do
  before(:each) do
    common_setup
    @args.push("--redirect-stderr-to-stdout")
  end

  it "should return redirect_stderr_to_stdout flag as true in options hash" do
    @arg_parser.parse(@args)
    @options[:redirect_stderr_to_stdout].should==(true)
  end
end

describe "an ArgParser instance with rogue-gems option" do
  before(:each) do
    common_setup
  end

  it "specified by --print-rogue-gems should return rogue_gems flag as true in options hash" do
    @args.push("--print-rogue-gems")
    @arg_parser.parse(@args)
    @options[:print_rogue_gems].should==(true)
  end

  it "specified by -p should return rogue_gems flag as true in options hash" do
    @args.push("-p")
    @arg_parser.parse(@args)
    @options[:print_rogue_gems].should==(true)
  end
end

describe "an ArgParser instance with version option" do
  before(:each) do
    common_setup
    @args.push("--version")
  end

  it "should return version" do
    @arg_parser.parse(@args)
    output = @arg_parser.output
    output.should match(/#{GemInstaller.version}/)
  end
end

describe "an ArgParser instance with sudo option" do
  before(:each) do
    common_setup
    @args.push("--sudo")
  end

  it "should return error message (sudo is not yet supported when GemInstaller is invoked programatically)" do
    @arg_parser.parse(@args)
    @arg_parser.output.should match(/The sudo option is not .* supported.*/)
  end
end

def common_setup
  @arg_parser = GemInstaller::ArgParser.new
  @args = []
  @options = {}
  @geminstaller_output_default = [:error,:install,:info]
  @rubygems_output_default = [:stderr]
  @arg_parser.options = @options
end

def verify_usage_output
  @arg_parser.parse(@args)
  output = @arg_parser.output
  output.should match(/Usage: geminstaller.*/)
end


