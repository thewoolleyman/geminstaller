dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "The geminstaller command line application" do
  before(:each) do
    GemInstaller::TestGemHome.use
    
    @mock_output_proxy = mock("Mock Output Proxy")
    @registry = GemInstaller::create_registry
    @application = @registry.app
    @output_filter = @registry.output_filter
    @output_filter.output_proxy = @mock_output_proxy
    
    @gem_command_manager = @registry.gem_command_manager
    @gem_spec_manager = @registry.gem_spec_manager
    @valid_platform_selector = @registry.valid_platform_selector
    @sample_gem = sample_gem
  end

  it "should print usage if --help arg is specified" do
    @application.args = ["--help"]
    @mock_output_proxy.should_receive(:sysout).with(/^Usage.*/)
    @application.run
  end
  
  it "should install gem if it is not already installed" do
    @application.args = geminstaller_spec_test_args
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  it "should handle 'current' as a valid platform" do
    gem = @sample_gem
    # force ruby platform to match 'remote' gem's platform
    @valid_platform_selector.ruby_platform = gem.platform
  
    # reset gem's platform to current
    gem.platform = 'current'
  
    @application.args = geminstaller_spec_test_args
    @sample_gem.platform = 'current'
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  it "should print startup message in debug mode" do
    @gem_command_manager.install_gem(@sample_gem)
    args = ["--geminstaller-output=debug","--config=#{geminstaller_spec_live_config_path}"]
    @application.args = args
    @mock_output_proxy.should_receive(:sysout).with(/^GemInstaller is verifying gem installation: #{sample_gem_name}.*/)
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(anything())
    @application.run
  end
  

  it "should print message if gem is already installed" do
    @gem_command_manager.install_gem(@sample_gem)
    args = ["--geminstaller-output=debug","--config=#{geminstaller_spec_live_config_path}"]
    @application.args = args
    @mock_output_proxy.should_receive(:sysout).with(/^Gem .* is already installed/)
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(anything())
    @application.run
  end
  
  it "should print error if --sudo option is specified (it's only supported if geminstaller is invoked via GemInstaller class, which strips out the option)" do
    @application.args = ["--sudo","--config=#{geminstaller_spec_live_config_path}"]
    @mock_output_proxy.should_receive(:syserr).once().with(/^The sudo option is not .* supported/)
    @application.run
  end
  
  it "redirects stderr to stdout" do
    begin
      @application.args = ["--config=bogus_config_file.yml","--redirect-stderr-to-stdout"]
      @original_stdout = $stdout
      @mock_stdout = MockStdout.new
      $stdout = @mock_stdout
      @original_stderr = $stderr
      @mock_stderr = MockStderr.new
      $stderr = @mock_stderr
      @output_proxy = @registry.output_proxy
      @output_filter.output_proxy = @output_proxy
      @application.run
      @mock_stdout.out.should match(/^Error/)
      @mock_stderr.err.should ==(nil)
    ensure
      $stdout = @original_stdout
      $stderr = @original_stderr
    end
  end
  
  it "should install a platform-specific binary gem" do
    @sample_multiplatform_gem = sample_multiplatform_gem
    @gem_command_manager.uninstall_gem(@sample_multiplatform_gem) if @gem_spec_manager.is_gem_installed?(@sample_multiplatform_gem)
    @application.args = ["--silent","--config=#{dir}/live_geminstaller_config_2.yml"]
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_multiplatform_gem).should==(true)
  end
  
  it "should install correctly even if install_options is not specified" do
    @application.args = ["--silent","--config=#{dir}/live_geminstaller_config_3.yml"]
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  it "should not give an error if a config file with no gems is loaded" do
    @application.args = ["--config=#{dir}/empty_geminstaller_config.yml"]
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(/No gems found/m)
    @application.run
  end
  
  it "should show error if a version specification is not met" do
    @application.args = ["--config=#{dir}/live_geminstaller_config_4.yml"]
    @mock_output_proxy.should_receive(:syserr).with(/^The specified version requirement '> 1.0.0' for gem 'stubgem' is not met by any of the available versions: 1.0.0./)
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(anything())
    @application.run
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(false)
  end
   
  it "should handle a multiplatform dependency chain" do
    @application.args = ["--config=#{dir}/live_geminstaller_config_5.yml"]
    @mock_output_proxy.should_receive(:sysout).with(/^Invoking gem install for #{sample_dependent_depends_on_multiplatform_gem.name}.*/)
    @mock_output_proxy.should_receive(:sysout).with(/^Rubygems automatically installed dependency gem #{sample_multiplatform_gem.name}-#{sample_multiplatform_gem.version}/)
    @mock_output_proxy.should_receive(:sysout).any_number_of_times.with(anything())
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

  after(:each) do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
   
end

describe "The geminstaller command line application created via GemInstaller.run method" do
  before(:each) do
    GemInstaller::TestGemHome.use
  end

  it "should run successfully" do
    result = GemInstaller.run(geminstaller_spec_test_args)
    result.should equal(0)
  end

  after(:each) do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end

describe "The GemInstaller.autogem method" do
  before(:each) do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @gem_spec_manager = @registry.gem_spec_manager
    @gem_runner_proxy = @registry.gem_runner_proxy
    # Clear out loaded specs in rubygems, otherwise the gem call won't do anything
    Gem.instance_eval { @loaded_specs.clear if @loaded_specs }

    @expected_load_path_entry = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/lib"
    @expected_load_path_entry_bin = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/bin"
    @expected_load_path_entry_2 = "#{test_gem_home_dir}/gems/#{sample_multiplatform_gem_name}-#{sample_multiplatform_gem_version}-mswin32/lib"
    @expected_load_path_entry_2_bin = "#{test_gem_home_dir}/gems/#{sample_multiplatform_gem_name}-#{sample_multiplatform_gem_version}-mswin32/bin"
    GemInstaller.run(["--silent","--config=#{geminstaller_spec_live_config_path},#{geminstaller_spec_live_config_2_path}"])
    @gem_spec_manager.is_gem_installed?(sample_gem).should==(true)
    @gem_spec_manager.is_gem_installed?(sample_multiplatform_gem).should==(true)
    $:.delete(@expected_load_path_entry)
    $:.delete(@expected_load_path_entry_bin)
    $:.delete(@expected_load_path_entry_2)
    $:.delete(@expected_load_path_entry_2_bin)
    $:.should_not include(@expected_load_path_entry)
    $:.should_not include(@expected_load_path_entry_bin)
    $:.should_not include(@expected_load_path_entry_2)
    $:.should_not include(@expected_load_path_entry_2_bin)
  end

  it "should add a specified gem to the load path" do

    # These lines are required or else the GemInstaller.autogem command can't find the stubgem in the
    # test gem home.  I'm not sure why.
    if RUBYGEMS_VERSION_CHECKER.matches?('< 0.9')
      runner = Gem::GemRunner.new()
    else
      runner = Gem::GemRunner.new(:command_manager => Gem::CommandManager)
    end
    runner.do_configuration(['list'])    

    added_gems = GemInstaller.autogem("--config=#{geminstaller_spec_live_config_path},#{geminstaller_spec_live_config_2_path} --exceptions")
    added_gems.should be_a_kind_of(Array)
    added_gems.should include(sample_gem)
    added_gems.should include(sample_multiplatform_gem)
    $:.should include(@expected_load_path_entry)
    $:.should include(@expected_load_path_entry_bin)
    $:.should include(@expected_load_path_entry_2)
    $:.should include(@expected_load_path_entry_2_bin)
  end

  it "should handle ignored args like sudo" do
    # These lines are required or else the GemInstaller.autogem command can't find the stubgem in the
    # test gem home.  I'm not sure why.
    if RUBYGEMS_VERSION_CHECKER.matches?('< 0.9')
      runner = Gem::GemRunner.new()
    else
      runner = Gem::GemRunner.new(:command_manager => Gem::CommandManager)
    end
    runner.do_configuration(['list'])

    args_that_should_be_ignored_by_autogem = '-d -p -rall -s'
    added_gems = GemInstaller.autogem("--config=#{geminstaller_spec_live_config_path},#{geminstaller_spec_live_config_2_path} -e -gall #{args_that_should_be_ignored_by_autogem}")
    added_gems.should be_a_kind_of(Array)
    added_gems.should include(sample_gem)
    added_gems.should include(sample_multiplatform_gem)
    $:.should include(@expected_load_path_entry)
    $:.should include(@expected_load_path_entry_bin)
    $:.should include(@expected_load_path_entry_2)
    $:.should include(@expected_load_path_entry_2_bin)
  end

  it "should handle exceptions" do
    result = GemInstaller.autogem('-cbogus_config_path')
    result.should ==(1)
  end

  after(:each) do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end

def geminstaller_spec_live_config_path
  dir = File.dirname(__FILE__)
  "#{dir}/live_geminstaller_config.yml"
end

def geminstaller_spec_live_config_2_path
  dir = File.dirname(__FILE__)
  "#{dir}/live_geminstaller_config_2.yml"
end

def geminstaller_spec_test_args
  ["--silent","--config=#{geminstaller_spec_live_config_path}"]
end
