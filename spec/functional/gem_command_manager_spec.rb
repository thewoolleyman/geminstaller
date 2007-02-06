dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a GemCommandManager instance" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::SpecUtils::TestGemHome.use
    extra_install_options = install_options_for_testing
    extra_install_options << "-y" << "--backtrace"
    @sample_gem_with_extra_install_options = GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => extra_install_options)
    @sample_gem = sample_gem
    @sample_multiplatform_gem = sample_multiplatform_gem
    @nonexistent_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => "0.0.37", :install_options => install_options_for_testing)
    @unspecified_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name,:install_options => install_options_for_testing)
    @gem_command_manager = GemInstaller::DependencyInjector.new.registry.gem_command_manager

    GemInstaller::SpecUtils::EmbeddedGemServer.start

    # setup to make sure gems are not installed before test
    [@sample_gem, @sample_multiplatform_gem].each do |gem|
      if (@gem_command_manager.is_gem_installed(gem)) then
        @gem_command_manager.setup_noninteractive_chooser(:uninstall_list_type, gem)
        @gem_command_manager.uninstall_gem(gem)
      end
      @gem_command_manager.is_gem_installed(gem).should==(false)
    end
  end
  
  teardown do
    GemInstaller::SpecUtils::TestGemHome.reset
  end

  specify "should be able to install, uninstall, and check for existence of specific versions of a gem" do
    @gem_command_manager.install_gem(@sample_gem_with_extra_install_options)
  
    @gem_command_manager.is_gem_installed(@sample_gem).should==(true)
    @gem_command_manager.is_gem_installed(@nonexistent_version_sample_gem).should==(false)
  
    # uninstall it again after we are done
    @gem_command_manager.uninstall_gem(@sample_gem)
    @gem_command_manager.is_gem_installed(@sample_gem).should==(false)
  end

  specify "should be able to list remote gems" do
    list_options = ["--source=#{local_gem_server_url}"]
    @sample_gem.name = 'stubgem-multiplatform'
    list = @gem_command_manager.list_remote_gem(@sample_gem,list_options)
    expected_list = ["",
      "*** REMOTE GEMS ***", 
      "", 
      "stubgem-multiplatform (1.0.1, 1.0.0)", 
      "    Multiplatform stub gem for testing geminstaller"]
    list.should==(expected_list)
  end
  
  specify "should be able to install and uninstall similarly named gems without a prompt (using exact name matching)" do
    gems = [@sample_gem, @sample_multiplatform_gem]
    gems.each do |gem|
      @gem_command_manager.install_gem(gem)
      @gem_command_manager.is_gem_installed(gem).should==(true)
    end
  
    # uninstall it again after we are done
    gems.each do |gem|
      @gem_command_manager.uninstall_gem(gem)
      @gem_command_manager.is_gem_installed(gem).should==(false)
    end
  end
  
  specify "should be able to install two gems with the same version but different platforms" do
    @sample_multiplatform_gem_for_another_platform = sample_multiplatform_gem
    @sample_multiplatform_gem_for_another_platform.platform = 'ruby'
    @gem_command_manager.uninstall_gem(@sample_multiplatform_gem_for_another_platform)
    gems = [@sample_multiplatform_gem, @sample_multiplatform_gem_for_another_platform]
    gems.each do |gem|
      @gem_command_manager.install_gem(gem)
      @gem_command_manager.is_gem_installed(gem).should==(true)
    end
  
    # uninstall it again after we are done
    gems.each do |gem|
      @gem_command_manager.uninstall_gem(gem)
      @gem_command_manager.is_gem_installed(gem).should==(false)
    end
  end

end
