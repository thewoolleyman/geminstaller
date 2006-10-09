dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/ruby_gem")

context "A gem" do
  setup do
    @gem = GemInstaller::RubyGem.new('mygem', 'v1.1', '-y')
  end

  specify "should contain a name, a version, and install options" do
    @gem.name.should_equal('mygem')
    @gem.version.should_equal('v1.1')
    @gem.install_options.should_equal('-y')
  end
end
