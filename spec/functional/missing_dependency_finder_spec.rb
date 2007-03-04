dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a MissingDependencyFinder instance" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @missing_dependency_finder = @registry.missing_dependency_finder
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

  specify "should return all missing dependencies, and inherit install_options from dependent" do
    # uninstall the dependencies
    [@sample_gem, @sample_multiplatform_gem].each do |gem|
      gem.install_options << '--ignore-dependencies'
      uninstall_gem(gem)
    end
    @sample_dependent_gem.install_options << '--no-test'
    @sample_dependent_multiplatform_gem.install_options << '--rdoc'
    gems_with_missing_dependencies = [@sample_dependent_gem, @sample_dependent_multiplatform_gem]
    missing_dependencies = @missing_dependency_finder.find(gems_with_missing_dependencies)
    missing_dependencies[0].name.should==(@sample_gem.name)
    missing_dependencies[0].version.should==('>= 1.0.0')
    missing_dependencies[0].install_options.should_include('--no-test')
    missing_dependencies[1].name.should==(@sample_multiplatform_gem.name)
    missing_dependencies[1].version.should==('>= 1.0.0')
    missing_dependencies[1].install_options.should_include('--rdoc')
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
