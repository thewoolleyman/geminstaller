dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/yaml_loader")

context "YamlLoader instance" do
  specify "should load yaml" do
    yaml_text = 'key: value'
    yaml_loader = GemInstaller::YamlLoader.new(yaml_text)
    yaml = yaml_loader.load
    'value'.should_equal(yaml['key'])
  end
end
