dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/gem_command_proxy")

# NOTE: this test is dependent upon RubyGems being installed, and write permissions (or sudo) to gem install dir
context "a GemCommandProxy instance" do
  setup do
    @sample_gem = "ruby-doom"
    @gem_command_proxy = GemInstaller::GemCommandProxy.new

    # setup to make sure gem is not installed before test
    if (@gem_command_proxy.is_gem_installed(@sample_gem)) then
      @gem_command_proxy.uninstall_gem(@sample_gem)
    end
    @gem_command_proxy.is_gem_installed(@sample_gem).should_equal(false)
  end

  specify "should be able to install and delete a gem" do
    @gem_command_proxy.install_gem(@sample_gem)

    @gem_command_proxy.is_gem_installed(@sample_gem).should_equal(true)

    # uninstall it again after we are done
    @gem_command_proxy.uninstall_gem(@sample_gem)
    @gem_command_proxy.is_gem_installed(@sample_gem).should_equal(false)
  end
  
end
