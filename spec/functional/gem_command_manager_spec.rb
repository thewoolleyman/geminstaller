dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/gem_command_manager")
require File.expand_path("#{dir}/../../lib/geminstaller/dependency_injector")
require File.expand_path("#{dir}/../../lib/geminstaller/ruby_gem")

# NOTE: this test is dependent upon
# * RubyGems being installed
# * write permissions (or sudo) to gem install dir
# * rubyforge.org being up and accessible
# If rubyforge.org is down or inaccessible, you can point the --source option to a local server running gem_server
context "a GemCommandManager instance" do
  setup do
    # provide an easy flag to skip this test, since it will fail if rubyforge is down or there is no network connectivity
    @skip_test = false
    p "WARNING: test is disabled..." if @skip_test
    sample_gem_name = "ruby-doom"
#    sample_gem_name = "mocha"
    source_param = ["--source", "http://gems.rubyforge.org"]
#    source_param = ["--source", "http://someserver:8808"]
    version = "0.8"
#    version = "0.1.2"
    @sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => version, :install_options => source_param)
    @nonexistent_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => "0.0.37", :install_options => source_param)
    @unspecified_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name,:install_options => source_param)
    @gem_command_manager = GemInstaller::DependencyInjector.new.registry.gem_command_manager

    # setup to make sure gem is not installed before test
    if (@gem_command_manager.is_gem_installed(@sample_gem)) then
      @gem_command_manager.uninstall_gem(@sample_gem)
    end
    @gem_command_manager.is_gem_installed(@sample_gem).should_equal(false)
  end

  specify "should be able to install, uninstall, and check for existence of specific versions of a gem" do
    return if @skip_test
    @gem_command_manager.install_gem(@sample_gem)

    @gem_command_manager.is_gem_installed(@sample_gem).should_equal(true)
    @gem_command_manager.is_gem_installed(@nonexistent_version_sample_gem).should_equal(false)

    # uninstall it again after we are done
    @gem_command_manager.uninstall_gem(@sample_gem)
    @gem_command_manager.is_gem_installed(@sample_gem).should_equal(false)
  end
  
  specify "should be able to install, uninstall, and check for existence of unspecified version of a gem" do
    return if @skip_test
    @gem_command_manager.install_gem(@unspecified_version_sample_gem)

    @gem_command_manager.is_gem_installed(@unspecified_version_sample_gem).should_equal(true)

    # uninstall it again after we are done
    @gem_command_manager.uninstall_gem(@unspecified_version_sample_gem)
    @gem_command_manager.is_gem_installed(@unspecified_version_sample_gem).should_equal(false)
  end
end
