dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "the RubyVersionChecker" do
  it "should correctly determine 'less_than' for compared versions" do
    rubygems_version_checker = GemInstaller::RubyGemsVersionChecker.new
    rubygems_version_checker.less_than?('2','1').should be_true
    rubygems_version_checker.less_than?('0.0.2','0.0.1').should be_true
    rubygems_version_checker.less_than?('0.0.1','0.0.2').should be_false
  end
end