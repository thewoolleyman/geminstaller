dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "A ruby gem data object" do
  setup do
  end

  specify "may be instantiated with a name, a version, a platform, and install options" do
    gem = GemInstaller::RubyGem.new('mygem', :version => 'v1.1', :platform => "ruby", :install_options => '-y')
    gem.name.should==('mygem')
    gem.version.should==('v1.1')
    gem.platform.should==('ruby')
    gem.install_options.should==('-y')
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
end
