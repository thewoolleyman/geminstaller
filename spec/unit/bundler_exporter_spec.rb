dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "BundlerExporter" do
  before(:each) do
    @yaml_text = <<-STRING_END
      gems:
        - name: mygem
          version: '> 0.1'
    STRING_END
    @yaml = YAML.load(@yaml_text)
    @config = GemInstaller::Config.new(@yaml)
    @bundler_exporter = GemInstaller::BundlerExporter.new
    @mock_output_proxy = mock("Mock OutputProxy")
    @bundler_exporter.output_proxy = @mock_output_proxy
  end

  it "should convert a geminstaller config into a bundler manifest" do
    manifest = @bundler_exporter.convert(@config)
    manifest.should match(/^gem "mygem", "> 0.1"/m)
  end
  
  it "should output" do
    @mock_output_proxy.should_receive(:sysout).with(%Q{gem "mygem", "> 0.1"\n})
    @bundler_exporter.output(@config)
  end
end

