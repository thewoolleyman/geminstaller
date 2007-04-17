dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an GemSpecManager instance" do
  setup do
    GemInstaller::TestGemHome.use
    @sample_gem = sample_gem
    @sample_multiplatform_gem = sample_multiplatform_gem
    @registry = GemInstaller::create_registry
    @gem_spec_manager = @registry.gem_spec_manager
    @gem_command_manager = @registry.gem_command_manager

    GemInstaller::EmbeddedGemServer.start
  end

  specify "can list a local matching gem" do
    install_gem(@sample_gem)
    matching_gems = @gem_spec_manager.local_matching_gems(@sample_gem)
    matching_gems.size.should == 1
    matching_gems[0].name.should == @sample_gem.name

    non_matching_gems = @gem_spec_manager.local_matching_gems(@sample_multiplatform_gem)
    non_matching_gems.size.should == 0
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


