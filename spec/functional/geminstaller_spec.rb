dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "The geminstaller command line application" do
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
    
    @mock_output_proxy = mock("Mock Output Proxy")
    @registry = GemInstaller::create_registry
    @application = @registry.app
    @output_filter = @registry.output_filter
    @output_filter.output_proxy = @mock_output_proxy
    
    @gem_command_manager = @registry.gem_command_manager
    @gem_spec_manager = @registry.gem_spec_manager
    @sample_gem = sample_gem
  end

  specify "should print usage if --help arg is specified" do
    @application.args = ["--help"]
    @mock_output_proxy.should_receive(:sysout).with(/Usage.*/)
    @application.run
  end
  
  specify "should install gem if it is not already installed" do
    @application.args = geminstaller_spec_test_args
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  specify "should handle 'current' as a valid platform" do
    @application.args = geminstaller_spec_test_args
    @sample_gem.platform = 'current'
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  specify "should print message if gem is already installed" do
    @gem_command_manager.install_gem(@sample_gem)
    args = ["--geminstaller-output=debug","--config=#{geminstaller_spec_live_config_path}"]
    @application.args = args
    @mock_output_proxy.should_receive(:sysout).with(/Gem .* is already installed/)
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(:anything)
    @application.run
  end
  
  specify "should print error if --sudo option is specified (it's only supported if geminstaller is invoked via bin/geminstaller, which strips out the option)" do
    @application.args = ["--sudo","--config=#{geminstaller_spec_live_config_path}"]
    @mock_output_proxy.should_receive(:sysout).with(/The sudo option is not .* supported.*/)
    @application.run
  end
  
  specify "should install a platform-specific binary gem" do
    @sample_multiplatform_gem = sample_multiplatform_gem
    @gem_command_manager.uninstall_gem(@sample_multiplatform_gem) if @gem_spec_manager.is_gem_installed?(@sample_multiplatform_gem)
    @application.args = ["--silent","--config=#{dir}/live_geminstaller_config_2.yml"]
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_multiplatform_gem).should==(true)
  end
  
  specify "should install correctly even if install_options is not specified" do
    @application.args = ["--silent","--config=#{dir}/live_geminstaller_config_3.yml"]
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  specify "should show error if a version specification is not met" do
    @application.args = ["--config=#{dir}/live_geminstaller_config_4.yml"]
    @mock_output_proxy.should_receive(:sysout).with(/The specified version requirement '> 1.0.0' is not met by any of the available versions: 1.0.0./)
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(:anything)
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(false)
  end
   
  specify "should handle a multiplatform dependency chain" do
    @application.args = ["--config=#{dir}/live_geminstaller_config_5.yml"]
    @mock_output_proxy.should_receive(:sysout).with(/GemInstaller is verifying gem installation: #{sample_dependent_depends_on_multiplatform_gem.name}.*/)
    @mock_output_proxy.should_receive(:sysout).with(/Invoking gem install for #{sample_dependent_depends_on_multiplatform_gem.name}.*/)
    @mock_output_proxy.should_receive(:sysout).with(/Rubygems automatically installed dependency gem #{sample_multiplatform_gem.name}-#{sample_multiplatform_gem.version}/)
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(:anything)
    @application.run
    @gem_spec_manager.is_gem_installed?(sample_dependent_depends_on_multiplatform_gem).should==(true)
    expected_dependency_gem = nil
    if RUBY_PLATFORM =~ /mswin/
      expected_dependency_gem = sample_multiplatform_gem
    else
      expected_dependency_gem = sample_multiplatform_gem_ruby
    end
    @gem_spec_manager.is_gem_installed?(expected_dependency_gem).should==(true)
  end

  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
   
end

context "The geminstaller command line application created via GemInstaller.run method" do
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
  end

  specify "should run successfully" do
    result = GemInstaller.run(geminstaller_spec_test_args)
    result.should_equal(0)
  end

  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end

context "The GemInstaller.autogem method" do
  specify "should add a specified gem to the load path" do
    # Clear out loaded specs in rubygems, otherwise the gem call won't do anything
    Gem.instance_eval { @loaded_specs.clear if @loaded_specs }
    expected_load_path_entry = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/lib"
    expected_load_path_entry_bin = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/bin"
    GemInstaller.run(geminstaller_spec_test_args)
    $:.delete(expected_load_path_entry)
    $:.delete(expected_load_path_entry_bin)
    $:.should_not_include(expected_load_path_entry)
    $:.should_not_include(expected_load_path_entry_bin)
    added_gems = GemInstaller.autogem(geminstaller_spec_live_config_path)
    added_gems[0].should ==(sample_gem)
    $:.should_include(expected_load_path_entry)
    $:.should_include(expected_load_path_entry_bin)
  end

  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end

def geminstaller_spec_live_config_path
  dir = File.dirname(__FILE__)
  "#{dir}/live_geminstaller_config.yml"
end

def geminstaller_spec_test_args
  ["--silent","--config=#{geminstaller_spec_live_config_path}"]
end