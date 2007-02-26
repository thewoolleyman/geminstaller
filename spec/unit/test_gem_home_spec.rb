dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")

context "test_gem_home_spec: the TestGemHome class" do
  include GemInstaller::SpecUtils
  include FileUtils
  
  setup do
    @test_gem_home_dir = GemInstaller::SpecUtils.test_gem_home_dir
  end
  
  specify "should delete and recreate a test gem home" do
    # remove dir if it exists
    GemInstaller::TestGemHome.reset

    # use should create dir
    GemInstaller::TestGemHome.use

    # make sure rubygems dirs, including source_index, were created
    entries = Dir.entries("#{@test_gem_home_dir}")
    ["bin","gems","source_cache"].each do |expected_subdir|
      entries.should_include(expected_subdir)
    end
  end
end
