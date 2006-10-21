dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "A config builder with mock dependencies" do
  setup do
    @mock_file_reader = mock("Mock FileReader")
    @mock_yaml_loader = mock("Mock YamlLoader")
    
    @config_builder = GemInstaller::ConfigBuilder.new
    @config_builder.file_reader = @mock_file_reader
    @config_builder.yaml_loader = @mock_yaml_loader
    
    @stub_file_contents
    @yaml_text = <<-STRING_END
      gems:
        - name: mygem
    STRING_END
  end
  
  specify "should be able to read a file and build a config" do
    @mock_file_reader.should_receive(:read).and_return(@stub_file_contents)
    @mock_yaml_loader.should_receive(:load).with(@stub_file_contents).and_return(@yaml_text)

    config = @config_builder.build_config
    config.gems[0].name.should_equal(@mygem)
  end
end
