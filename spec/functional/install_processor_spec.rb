dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an InstallProcessor instance" do
  setup do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @install_processor = @registry.install_processor
    @mock_output_filter = mock("Mock Output Filter")
    @install_processor.output_filter = @mock_output_filter

    @missing_dependency_finder = @registry.missing_dependency_finder
    @missing_dependency_finder.output_filter = @mock_output_filter

    @gem_command_manager = @registry.gem_command_manager
    @sample_gem = sample_gem
    @sample_dependent_gem = sample_dependent_gem
    @sample_multiplatform_gem = sample_multiplatform_gem_ruby
    @sample_dependent_multiplatform_gem = sample_dependent_multiplatform_gem
    @sample_dependent_multilevel_gem = sample_dependent_multilevel_gem

    GemInstaller::EmbeddedGemServer.start
    # ensure all gems are installed to start
    [@sample_gem, @sample_dependent_gem, @sample_dependent_multilevel_gem].each do |gem|
      install_gem(gem)
    end
  end

  specify "should install a missing dependency at the bottom of a multilevel dependency chain" do
    # uninstall the dependency
    @sample_gem.install_options << '--ignore-dependencies'
    uninstall_gem(@sample_gem)

    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/Gem #{@sample_dependent_multilevel_gem.name}, version 1.0.0 is already installed/m)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/Missing dependencies found for #{@sample_dependent_gem.name} \(1.0.0\)/m)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/  #{@sample_gem.name} \(>= 1.0.0\)/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Installing #{@sample_gem.name} \(>= 1.0.0\)/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Invoking gem install for #{@sample_gem.name}, version 1.0.0/)

    @install_processor.process([@sample_dependent_multilevel_gem])
    @gem_command_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  specify "should install missing dependencies in middle and bottom of a multilevel dependency chain" do
    # uninstall the dependencies
    [@sample_gem, @sample_dependent_gem].each do |gem|
      gem.install_options << '--ignore-dependencies'
      uninstall_gem(gem)
    end

    options = {:info => true}
    @install_processor.options = options

    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/Gem #{@sample_dependent_multilevel_gem.name}, version 1.0.0 is already installed/m)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/Missing dependencies found for #{@sample_dependent_multilevel_gem.name} \(1.0.0\)/m)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/  #{@sample_dependent_gem.name} \(>= 1.0.0\)/)
    # TODO: info option results in duplicate installation messages
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Installing #{@sample_dependent_gem.name} \(>= 1.0.0\)/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Invoking gem install for #{@sample_dependent_gem.name}, version 1.0.0/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Rubygems automatically installed dependency gem #{@sample_gem.name}-#{@sample_gem.version}/)

    @install_processor.process([@sample_dependent_multilevel_gem])
    @gem_command_manager.is_gem_installed?(@sample_dependent_gem).should==(true)
    @gem_command_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  specify "should install missing dependencies at top and bottom of a multilevel dependency chain" do
    # uninstall the gems
    [@sample_gem, @sample_dependent_multilevel_gem].each do |gem|
      gem.install_options << '--ignore-dependencies'
      uninstall_gem(gem)
    end

    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/Missing dependencies found for #{@sample_dependent_gem.name} \(1.0.0\)/m)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:info,/  #{@sample_gem.name} \(>= 1.0.0\)/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Invoking gem install for #{@sample_dependent_multilevel_gem.name}, version 1.0.0/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Invoking gem install for #{@sample_gem.name}, version 1.0.0/)
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:install,/Installing #{@sample_gem.name} \(>= 1.0.0\)/)

    @install_processor.process([@sample_dependent_multilevel_gem])
    @gem_command_manager.is_gem_installed?(@sample_dependent_multilevel_gem).should==(true)
    @gem_command_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
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
