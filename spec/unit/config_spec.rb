dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/config")

context "YAML containing a single gem" do
  setup do
    @yaml_text = <<-STRING_END
      gems:
        mygem:
          version: 1.1
    STRING_END
    @yaml = YAML.load(@yaml_text)
    @config = GemInstaller::Config.new(@yaml)
  end

  specify "should be parsed into a corresponding gem object" do
    gem = @config.gems[0]
    gem.name.should_equal('mygem')
    gem.version.should_equal('1.1')
  end
end
