dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "test_gem_home_spec: the TestGemHome class" do
  include FileUtils
  
  before(:each) do
    @test_gem_home_dir = test_gem_home_dir
  end
  
  it "should create a test gem home" do
    # use should create dir
    GemInstaller::TestGemHome.use

    # make sure rubygems dirs, including source_index, were created
    entries = Dir.entries("#{@test_gem_home_dir}")
    expected_entries = ["cache", "doc", "gems", "specifications"]
    if GemInstaller::RubyGemsVersionChecker.matches?('>1.1.1')
      expected_entries << 'cache'
    else
      expected_entries << 'source_cache'
    end    
    
    expected_entries.each do |expected_subdir|
      entries.should include(expected_subdir)
    end
  end
end
