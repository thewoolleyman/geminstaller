dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "the RubyVersionChecker" do
  it "should correctly determine matches for gem specifications" do
    rubygems_version_checker = GemInstaller::RubyGemsVersionChecker.new
    rubygems_version_checker.matches?('< 2', :rubygems_version => '1').should be_true
    rubygems_version_checker.matches?('<2', :rubygems_version => '1').should be_true
    rubygems_version_checker.matches?('< 0.0.2', :rubygems_version => '0.0.1').should be_true
    rubygems_version_checker.matches?('< 0.0.1', :rubygems_version => '0.0.2').should be_false
    rubygems_version_checker.matches?(["~> 0.8","< 0.9"], :rubygems_version => '0.7.9').should be_false
    rubygems_version_checker.matches?(["~> 0.8","< 0.9"], :rubygems_version => '0.8.1').should be_true
    rubygems_version_checker.matches?(["~> 0.8","< 0.9"], :rubygems_version => '0.9').should be_false
  end
end