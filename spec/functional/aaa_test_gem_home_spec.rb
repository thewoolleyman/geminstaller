dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "test_gem_home_spec: the TestGemHome class" do
  include FileUtils
  
  it "should create a test gem home" do
    GemInstaller::TestGemHome.reset
    GemInstaller::TestGemHome.use

    # make sure rubygems dirs, were created
    entries = Dir.entries("#{test_gem_home_dir}")
    if GemInstaller::RubyGemsVersionChecker.matches?('<1.2.0')
      expected_entries = ["source_cache","cache", "doc", "gems", "specifications"]
    elsif GemInstaller::RubyGemsVersionChecker.matches?(['>=1.2.0','<1.3.4'])
      expected_entries = ["cache", "doc", "gems", "specifications"]
    else
      expected_entries = ["site_ruby"]
    end
    
    expected_entries.each do |expected_subdir|
      entries.should include(expected_subdir)
    end
  end
end
