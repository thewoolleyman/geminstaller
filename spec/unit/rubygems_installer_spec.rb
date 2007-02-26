dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")
require File.expand_path("#{dir}/../helper/rubygems_installer")

context "rubygems_installer_spec: the RubyGemsInstaller class" do
  include GemInstaller::SpecUtils

  setup do
    @install_dir = GemInstaller::SpecUtils.test_gem_home_dir
    @rubygems_dist_dir = GemInstaller::SpecUtils.rubygems_dist_dir
    @rubygems_installer = GemInstaller::RubyGemsInstaller.new
    FileUtils.rm_rf(@install_dir) if File.exist?(@install_dir)
    @rubygems_installer.install_dir = @install_dir
    @rubygems_installer.rubygems_dist_dir = @rubygems_dist_dir
  end
  
  specify "should install rubygems" do
    @rubygems_installer.install
    entries = Dir.entries("#{@install_dir}")
    entries.should_include("bin")
    ["bin", "cache", "doc", "gems", "lib", "specifications"].each do |expected_subdir|
      entries.should_include(expected_subdir)
    end
  end

end
