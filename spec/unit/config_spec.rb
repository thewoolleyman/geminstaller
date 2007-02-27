dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "config YAML containing a single gem" do
  setup do
    @yaml_text = <<-STRING_END
      gems:
        - name: mygem
          version: '> 0.1.2.3'
          platform: ruby
          install_options: -y
          check_for_upgrade: false
    STRING_END
    @yaml = YAML.load(@yaml_text)
    @config = GemInstaller::Config.new(@yaml)
  end

  specify "should be parsed into a corresponding gem object" do
    gem = @config.gems[0]
    gem.name.should==('mygem')
    gem.version.should==('> 0.1.2.3')
    gem.platform.should==('ruby')
    gem.install_options.should==(["-y"])
    gem.check_for_upgrade.should==(false)
  end
end

context "config YAML with only name and version specified" do
  setup do
    @yaml_text = <<-STRING_END
    # COMMENT 
    gems:
      - name: mygem
        version: '0.1.2.3'
    STRING_END
    @yaml = YAML.load(@yaml_text)
    @config = GemInstaller::Config.new(@yaml)
  end

  specify "should not raise error on nil platform, install_options, or check_for_upgrade" do
    gem = @config.gems[0]
    gem.name.should==('mygem')
    gem.version.should==('0.1.2.3')
  end
end

context "config YAML containing two gems with the same name but different versions" do
  setup do
    @yaml_text = <<-STRING_END
      gems:
        - name: mygem
          version: 1.1
          install_options: -y
        - name: mygem
          version: 1.2
          install_options: ["-y"]
    STRING_END
    @yaml = YAML.load(@yaml_text)
    @config = GemInstaller::Config.new(@yaml)
  end

  specify "should be parsed into a corresponding gem objects" do
    gem = @config.gems[0]
    gem.name.should==('mygem')
    gem.version.should==('1.1')
    gem.install_options.should==(["-y"])

    gem = @config.gems[1]
    gem.name.should==('mygem')
    gem.version.should==('1.2')
    gem.install_options.should==(["-y"])
    gem.check_for_upgrade.should==(false)
  end
end

context "config YAML containing default install_options" do
  setup do
    @yaml_text = <<-STRING_END
      defaults:
          install_options: -y
          check_for_upgrade: true
      gems:
        - name: mygem
          version: 1.1
    STRING_END
    @yaml = YAML.load(@yaml_text)
    @config = GemInstaller::Config.new(@yaml)
  end

  specify "should propogate default install_options into gem object" do
    gem = @config.gems[0]
    gem.name.should==('mygem')
    gem.version.should==('1.1')
    gem.install_options.should==(["-y"])
    gem.check_for_upgrade.should==(true)
  end
end

context "config YAML containing neither default install_options nor gem-specific install options" do
  setup do
    @yaml_text = <<-STRING_END
      gems:
        - name: mygem
          version: 1.1
    STRING_END
    @yaml = YAML.load(@yaml_text)
    @config = GemInstaller::Config.new(@yaml)
  end

  specify "should have no install_options set on gem object" do
    gem = @config.gems[0]
    gem.name.should==('mygem')
    gem.version.should==('1.1')
    gem.install_options.should==([])
    gem.check_for_upgrade.should==(false)
  end
end
