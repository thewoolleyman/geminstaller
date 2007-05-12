dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a GemCommandManager instance" do
  before(:each) do
    GemInstaller::TestGemHome.use
    extra_install_options = install_options_for_testing
    extra_install_options << "-y" << "--backtrace"
    @sample_gem_with_extra_install_options = GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => extra_install_options)
    @sample_gem = sample_gem
    @sample_dependent_gem = sample_dependent_gem
    @sample_multiplatform_gem = sample_multiplatform_gem
    @sample_dependent_multiplatform_gem = sample_dependent_multiplatform_gem
    @nonexistent_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => "0.0.37", :install_options => install_options_for_testing)
    @unspecified_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name,:install_options => install_options_for_testing)
    @registry = GemInstaller::create_registry
    @gem_command_manager = @registry.gem_command_manager
    @gem_spec_manager = @registry.gem_spec_manager
    @valid_platform_selector = @registry.valid_platform_selector

    GemInstaller::EmbeddedGemServer.start
  end

  it "should be able to install, uninstall, and check for existence of specific versions of a gem" do
    install_gem(@sample_gem_with_extra_install_options)
  
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
    @gem_spec_manager.is_gem_installed?(@nonexistent_version_sample_gem).should==(false)
  end
  
  it "should be able to list remote gems" do
    list_options = ["--source=#{embedded_gem_server_url}"]
    @sample_gem.name = 'stubgem-multiplatform'
    list = @gem_command_manager.list_remote_gem(@sample_gem,list_options)
    expected_list = ["\n",
      "*** REMOTE GEMS ***\n", 
      "\n", 
      "stubgem-multiplatform (1.0.1, 1.0.0)\n", 
      "    Multiplatform stub gem for testing geminstaller\n"]
    list.should==(expected_list)
  end
  
  it "should raise an error if attempting to install a gem with dependencies without -y option" do
    # ensure dependency gem is uninstalled
    @gem_command_manager.uninstall_gem(@sample_gem)
    sample_dependent_gem = @sample_dependent_gem.dup
    sample_dependent_gem.install_options = install_options_for_testing.dup
    exception = nil
    begin
      @gem_command_manager.install_gem(sample_dependent_gem)
    rescue GemInstaller::UnauthorizedDependencyPromptError => error
      exception = error
      expected_error_message = /RubyGems is prompting to install a required dependency.*Gem command was:.*install dependent-stubgem.*Gem command output was:.*Install required dependency stubgem/m
      error.message.should match(expected_error_message)
    end
    exception.class.should==(GemInstaller::UnauthorizedDependencyPromptError)
  end
  
  it "should be able to install and uninstall similarly named gems without a prompt (using exact name matching)" do
    gems = [@sample_gem, @sample_multiplatform_gem]
    gems.each do |gem|
      install_gem(gem)
    end
  end
  
  it "should be able to install two gems with the same version but different platforms" do
    @sample_multiplatform_gem_for_another_platform = sample_multiplatform_gem.dup
    @sample_multiplatform_gem_for_another_platform.platform = 'ruby'
    uninstall_gem(@sample_multiplatform_gem)
    uninstall_gem(@sample_multiplatform_gem_for_another_platform)
    gems = [@sample_multiplatform_gem, @sample_multiplatform_gem_for_another_platform]
    gems.each do |gem|
      install_gem(gem)
    end
  end
  
  it "should be able to automatically install a dependency gem when dependent gem is installed" do
    @sample_dependency_gem = sample_gem
    uninstall_gem(@sample_dependent_gem)
    uninstall_gem(@sample_gem)
    @sample_dependent_gem.install_options << "-y"
    install_gem(@sample_dependent_gem)
    @gem_spec_manager.is_gem_installed?(@sample_gem).should==(true)
  end
  
  it "should be able to automatically install a multiplatform dependency gem when a multiplatform dependent gem is installed" do
    uninstall_gem(@sample_dependent_multiplatform_gem)
    uninstall_gem(@sample_multiplatform_gem)
    @sample_dependent_multiplatform_gem.install_options << "-y"
    install_gem(@sample_dependent_multiplatform_gem)
    @gem_spec_manager.is_gem_installed?(@sample_multiplatform_gem).should==(true)
  end
  
  it "should be able to install and uninstall a gem with the 'current' platform" do
    gem = @sample_gem

    # force ruby platform to match 'remote' gem's platform
    @valid_platform_selector.ruby_platform = gem.platform

    # reset gem's platform to current
    gem.platform = 'current'
    @gem_spec_manager.is_gem_installed?(gem).should==(false)
    @gem_command_manager.install_gem(gem)
    @gem_spec_manager.is_gem_installed?(gem).should==(true)
  end
  
  it "should be able to list dependencies based on exact name match" do
    nonmatching_gem = sample_dependent_multiplatform_gem
    nonmatching_gem.install_options << '--include-dependencies'
    install_gem(nonmatching_gem)
    
    matching_gem = sample_dependent_gem
    matching_gem.install_options << '--include-dependencies'
    install_gem(matching_gem)
    dependency_output_gems = @gem_command_manager.dependency(sample_dependent_gem.name, sample_dependent_gem.version, sample_dependent_gem.install_options)
    dependency_output_gems.size.should==(1)
    dependency_output_gems[0].name.should==('stubgem')
    dependency_output_gems[0].version.should==('>= 1.0.0')
  end

  def install_gem(gem)
    @gem_command_manager.install_gem(gem)
    @gem_spec_manager.is_gem_installed?(gem).should==(true)
  end
  
  def uninstall_gem(gem)
    @gem_command_manager.uninstall_gem(gem)
    @gem_spec_manager.is_gem_installed?(gem).should==(false)
  end
  
  after(:each) do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end
