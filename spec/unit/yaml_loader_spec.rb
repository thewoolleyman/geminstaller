dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "YamlLoader instance" do
  include GemInstaller::SpecUtils
  
  setup do
    @yaml_loader = GemInstaller::YamlLoader.new
  end
  specify "should load yaml" do
    yaml = @yaml_loader.load('key: value')
    'value'.should==(yaml['key'])
  end

  specify "should raise an error if there is an error parsing the yaml" do
    @invalid_yaml_text = <<-STRING_END
    --- 
    -1: 1  
     - 1: 1
    STRING_END


    proc_should_raise_with_message(/Error: Received error while attempting to parse YAML.*/) { @yaml_loader.load(@invalid_yaml_text) }
  end
end
