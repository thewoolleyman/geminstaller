dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a MissingDependencyFinder instance" do
  setup do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @missing_dependency_finder = @registry.missing_dependency_finder
    @mock_output_filter = mock("Mock Output Filter")
    @missing_dependency_finder.output_filter = @mock_output_filter
    @gem_command_manager = @registry.gem_command_manager
    @gem_spec_manager = @registry.gem_spec_manager
    @sample_gem = sample_gem
    @sample_dependent_gem = sample_dependent_gem
    @sample_multiplatform_gem = sample_multiplatform_gem_ruby
    @sample_dependent_multiplatform_gem = sample_dependent_multiplatform_gem
    @sample_dependent_multilevel_gem = sample_dependent_multilevel_gem

    GemInstaller::EmbeddedGemServer.start
    # ensure all gems are installed to start
    [@sample_gem, @sample_dependent_gem, @sample_multiplatform_gem, 
      @sample_dependent_multiplatform_gem, @sample_dependent_multilevel_gem].each do |gem|
      install_gem(gem)
    end
  end

  specify "should return all missing dependencies, and inherit install_options from dependent, and force --include-dependencies option if not already set" do
    # uninstall the dependencies
    [@sample_gem, @sample_multiplatform_gem].each do |gem|
      gem.install_options << '--ignore-dependencies'
      uninstall_gem(gem)
    end
    @sample_dependent_gem.install_options << '--no-test'
    @sample_dependent_multiplatform_gem.install_options << '--rdoc'
    @sample_dependent_multiplatform_gem.install_options << '-y'
  
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info, /^Missing dependencies found for #{@sample_dependent_gem.name} \(1.0.0\)/m)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info, /^  #{@sample_gem.name} \(>= 1.0.0\)/)
    missing_dependencies = @missing_dependency_finder.find(@sample_dependent_gem)
    missing_dependencies[0].name.should==(@sample_gem.name)
    missing_dependencies[0].version.should==('>= 1.0.0')
    missing_dependencies[0].install_options.should include('--no-test')
    missing_dependencies[0].install_options.should include('--include-dependencies')
  
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info, /^Missing dependencies found for #{@sample_dependent_multiplatform_gem.name} \(1.0.0\)/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info, /^  #{@sample_multiplatform_gem.name} \(>= 1.0.0\)/)
    missing_dependencies = @missing_dependency_finder.find(@sample_dependent_multiplatform_gem)
    missing_dependencies[0].name.should==(@sample_multiplatform_gem.name)
    missing_dependencies[0].version.should==('>= 1.0.0')
    missing_dependencies[0].install_options.should include('--rdoc')
    missing_dependencies[0].install_options.should include('-y')
  end

  specify "should find a missing dependency at the bottom of a multilevel dependency chain" do
    # uninstall the dependencies
    @sample_gem.install_options << '--ignore-dependencies'
    uninstall_gem(@sample_gem)

    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info, /^Missing dependencies found for #{@sample_dependent_gem.name} \(1.0.0\)/m)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info, /^  #{@sample_gem.name} \(>= 1.0.0\)/)

    dependencies = @missing_dependency_finder.find(@sample_dependent_multilevel_gem)
    dependencies.size.should==(1)
    dependencies[0].name.should==("stubgem")    
  end
  
  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end

  def install_gem(gem)
    @gem_command_manager.install_gem(gem)
    @gem_spec_manager.is_gem_installed?(gem).should==(true)
  end
  
  def uninstall_gem(gem)
    @gem_command_manager.uninstall_gem(gem)
    @gem_spec_manager.is_gem_installed?(gem).should==(false)
  end  
end
