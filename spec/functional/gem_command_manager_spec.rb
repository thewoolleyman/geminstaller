dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

# TOOD: make the local gem server startup automatic, or at least a cleaner warning
# NOTE: this test is dependent upon
# * RubyGems being installed
# * write permissions (or sudo) to gem install dir
context "a GemCommandManager instance" do
  include GemInstaller::SpecUtils
  setup do
    # provide an easy flag to skip this test, since it will fail if there is no local gem server available
    @skip_test = skip_gem_server_functional_tests?
    p "WARNING: test is disabled..." if @skip_test
    extra_install_options = install_options_for_testing
    extra_install_options << "-y" << "--backtrace"
    @sample_gem_with_extra_install_options = GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => extra_install_options)
    @sample_gem = sample_gem
    @nonexistent_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => "0.0.37", :install_options => install_options_for_testing)
    @unspecified_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name,:install_options => install_options_for_testing)
    @gem_command_manager = GemInstaller::DependencyInjector.new.registry.gem_command_manager

    GemInstaller::SpecUtils::EmbeddedGemServer.start

    # setup to make sure gem is not installed before test
    if (@gem_command_manager.is_gem_installed(@sample_gem)) then
      @gem_command_manager.uninstall_gem(@sample_gem)
    end
    @gem_command_manager.is_gem_installed(@sample_gem).should==(false)
  end

  specify "should be able to install, uninstall, and check for existence of specific versions of a gem" do
    return if @skip_test
    @gem_command_manager.install_gem(@sample_gem_with_extra_install_options)

    @gem_command_manager.is_gem_installed(@sample_gem).should==(true)
    @gem_command_manager.is_gem_installed(@nonexistent_version_sample_gem).should==(false)

    # uninstall it again after we are done
    @gem_command_manager.uninstall_gem(@sample_gem)
    @gem_command_manager.is_gem_installed(@sample_gem).should==(false)
  end
  
  specify "should be able to install, uninstall, and check for existence of unspecified version of a gem" do
    return if @skip_test
    @gem_command_manager.install_gem(@unspecified_version_sample_gem)

    @gem_command_manager.is_gem_installed(@unspecified_version_sample_gem).should==(true)

    # uninstall it again after we are done
    @gem_command_manager.uninstall_gem(@unspecified_version_sample_gem)
    @gem_command_manager.is_gem_installed(@unspecified_version_sample_gem).should==(false)
  end
  
end
