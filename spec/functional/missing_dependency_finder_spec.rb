dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a MissingDependencyFinder instance" do
  include GemInstaller::SpecUtils
  setup do
    @missing_dependency_finder = GemInstaller::MissingDependencyFinder.new
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @gem_command_manager = @registry.gem_command_manager
    @sample_gem = sample_gem
    @sample_dependent_gem = sample_dependent_gem
    @sample_multiplatform_gem = sample_multiplatform_gem
    @sample_dependent_multiplatform_gem = sample_dependent_multiplatform_gem

    GemInstaller::EmbeddedGemServer.start
    # ensure all gems are installed to start
    [@sample_gem, @sample_dependent_gem, @sample_multiplatform_gem, @sample_dependent_multiplatform_gem].each do |gem|
      install_gem(gem)
    end
  end

  specify "should return all missing dependencies" do
    # uninstall the dependencies
    [@sample_gem, @sample_multiplatform_gem].each do |gem|
      gem.install_options << '--ignore-dependencies'
      uninstall_gem(gem)
    end
    gems_with_missing_dependencies = [@sample_dependent_gem, @sample_dependent_multiplatform_gem]
    missing_dependencies = @missing_dependency_finder.find(gems_with_missing_dependencies)
    # TODO: check versions, and multiple versions as well
    missing_dependencies[0].name.should==(@sample_gem.name)
    missing_dependencies[1].name.should==(@sample_multiplatform_gem.name)
  end
  
  def install_gem(gem)
    @gem_command_manager.install_gem(gem)
    @gem_command_manager.is_gem_installed?(gem).should==(true)
  end
  
  def uninstall_gem(gem)
    @gem_command_manager.uninstall_gem(gem)
    @gem_command_manager.is_gem_installed?(gem).should==(false)
  end  
end
