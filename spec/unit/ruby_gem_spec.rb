dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "A ruby gem data object" do
  setup do
  end

  specify "may be instantiated with a name, a version, a platform, install options, and check_for_upgrade flag" do
    gem = GemInstaller::RubyGem.new('mygem', :version => 'v1.1', :platform => "ruby", :install_options => '-y')
    gem.name.should==('mygem')
    gem.version.should==('v1.1')
    gem.platform.should==('ruby')
    gem.install_options.should==('-y')
    gem.check_for_upgrade.should==(true)
  end

  specify "should default the platform to ruby if it is not specified" do
    gem = GemInstaller::RubyGem.new('mygem', :version => 'v1.1')
    gem.name.should==('mygem')
    gem.version.should==('v1.1')
    gem.platform.should==('ruby')
  end

  specify "may be instantiated with only a name, and install options (unspecified version)" do
    gem = GemInstaller::RubyGem.new('mygem', :install_options => '-y')
    gem.name.should==('mygem')
    gem.install_options.should==('-y')
  end

  specify "may be instantiated with only a name, and install options (unspecified version)" do
    gem = GemInstaller::RubyGem.new('mygem', :version => '> 0.1.2.3')
    gem.version.should==('> 0.1.2.3')
  end

  specify "should be comparable on name, version, and platform" do
    gems = []
    gems << GemInstaller::RubyGem.new('3', :version => '2', :platform => '2', :install_options => '4')
    gems << GemInstaller::RubyGem.new('3', :version => '2', :platform => '1', :install_options => '3')
    gems << GemInstaller::RubyGem.new('3', :version => '1', :platform => '3', :install_options => '2')
    gems << GemInstaller::RubyGem.new('2', :version => '1', :platform => '3', :install_options => '1')
    gems << GemInstaller::RubyGem.new('1', :version => '1', :platform => '3', :install_options => '0')
    gems.sort!
    gems[0].install_options.should==('0')
    gems[1].install_options.should==('1')
    gems[2].install_options.should==('2')
    gems[3].install_options.should==('3')
    gems[4].install_options.should==('4')
  end

  specify "should return regexp_escaped_name" do
    gem = GemInstaller::RubyGem.new('mygem()')
    gem.regexp_escaped_name.should==('mygem\(\)')
  end
end
