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


  specify "should act as a proxy for GemSourceIndexProxy at this point in the refactoring" do
    
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
    @gem_command_manager.is_gem_installed?(gem).should==(true)
  end
  
end


