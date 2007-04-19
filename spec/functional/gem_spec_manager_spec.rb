dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an GemSpecManager instance" do
  setup do
    GemInstaller::TestGemHome.use
    @sample_gem = sample_gem
    @sample_multiplatform_gem = sample_multiplatform_gem
    @sample_multiplatform_gem_ruby = sample_multiplatform_gem_ruby
    @registry = GemInstaller::create_registry
    @gem_spec_manager = @registry.gem_spec_manager
    @gem_command_manager = @registry.gem_command_manager

    GemInstaller::EmbeddedGemServer.start
  end

  specify "should return true for is_gem_installed? if a gem is installed and false if it is not" do
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(false)
    @gem_command_manager.install_gem(@sample_gem)
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end

  specify "can list a local matching gem" do
    install_gem(@sample_gem)
    matching_gems = @gem_spec_manager.local_matching_gems(@sample_gem)
    matching_gems.size.should == 1
    matching_gems[0].name.should == @sample_gem.name
  
    non_matching_gems = @gem_spec_manager.local_matching_gems(@sample_multiplatform_gem)
    non_matching_gems.size.should == 0
  end
  
  specify "should select multiple valid platforms when listing local matching gems with exact_platform_match == false" do
    gem1 = @sample_multiplatform_gem
    gem2 = @sample_multiplatform_gem_ruby
    exact_platform_match = false
    # fixture_sanity_check
    gem1.name.should == gem2.name
    gem1.version.should == gem2.version
    gem1.platform.should_not == gem2.platform
    install_gem(gem1)
    install_gem(gem2)
    matching_gems = @gem_spec_manager.local_matching_gems(gem1, exact_platform_match)
    matching_gems.size.should == 2
  end
  
  specify "can list all local gems" do
    gems = [@sample_gem, @sample_multiplatform_gem]
    gems.each do |gem|
      install_gem(gem)
    end
    all_local_gems = @gem_spec_manager.all_local_gems
    local_gem_names = all_local_gems.collect do |gem|
      gem.name
    end
    local_gem_versions = all_local_gems.collect do |gem|
      gem.version
    end
    local_gem_names.should_include(@sample_gem.name)
    local_gem_names.should_include(@sample_multiplatform_gem.name)
    local_gem_versions.should_include(@sample_gem.version)
  end
  
  def install_gem(gem)
    @gem_command_manager.install_gem(gem)
    @gem_spec_manager.is_gem_installed?(gem).should==(true)
  end
  
  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end


