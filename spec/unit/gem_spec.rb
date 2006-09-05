dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/gem")

context "A gem" do
  setup do
    @gem = GemInstaller::Gem.new('mygem', 'v1.1')
  end

  specify "should contain a name and a version" do
    @gem.name.should_equal('mygem')
    @gem.version.should_equal('v1.1')
  end
end
