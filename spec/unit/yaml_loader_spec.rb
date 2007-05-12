dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "YamlLoader instance" do
  before(:each) do
    @yaml_loader = GemInstaller::YamlLoader.new
  end

  it "should load yaml" do
    yaml = @yaml_loader.load('key: value')
    'value'.should==(yaml['key'])
  end

  it "should load multiline yaml" do
    yaml = @yaml_loader.load("key1: value1\nkey2: value2")
    'value2'.should==(yaml['key2'])
  end

  it "should allow comments after yaml" do
    yaml = @yaml_loader.load("key1: value1 # here is a comment\nkey2: value2   # another comment")
    'value2'.should==(yaml['key2'])
  end

  it "should raise an error if there is an error parsing the yaml" do
    @invalid_yaml_text = <<-STRING_END
    --- 
    -1: 1  
     - 1: 1
    STRING_END


    proc_should_raise_with_message(/Error: Received error while attempting to parse YAML.*/) { @yaml_loader.load(@invalid_yaml_text) }
  end

  it "should handle value of '> 1' even if it is not surrounded by quotes or followed by a newline" do
    # TODO: make this pass, otherwise people must enclose version specs in quotes
    
    # key == '1'
    yaml_text = "key: > 1\n"
    # yaml parse error 
    yaml_text = "key: > 1"
    # key == '> 1'
    yaml_text = "key: '> 1'"

    yaml = @yaml_loader.load(yaml_text)
    yaml['key'].should == '> 1'
  end
end
