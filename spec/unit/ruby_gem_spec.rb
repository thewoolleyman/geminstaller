dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "A ruby gem data object" do
  setup do
  end

  specify "may be instantiated with a name, a version, and install options" do
    gem = GemInstaller::RubyGem.new('mygem', :version => 'v1.1', :install_options => '-y')
    gem.name.should_equal('mygem')
    gem.version.should_equal('v1.1')
    gem.install_options.should_equal('-y')
  end

  specify "may be instantiated with only a name, and install options (unspecified version)" do
    gem = GemInstaller::RubyGem.new('mygem', :install_options => '-y')
    gem.name.should_equal('mygem')
    gem.install_options.should_equal('-y')
  end
end
