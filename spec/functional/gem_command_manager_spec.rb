dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemCommandManager instance" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::TestGemHome.use
    extra_install_options = install_options_for_testing
    extra_install_options << "-y" << "--backtrace"
    @sample_gem_with_extra_install_options = GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => extra_install_options)
    @sample_gem = sample_gem
    @sample_dependent_gem = sample_dependent_gem
    @sample_multiplatform_gem = sample_multiplatform_gem
    @nonexistent_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name, :version => "0.0.37", :install_options => install_options_for_testing)
    @unspecified_version_sample_gem = GemInstaller::RubyGem.new(sample_gem_name,:install_options => install_options_for_testing)
    @registry = GemInstaller::create_registry
    @gem_command_manager = @registry.gem_command_manager

    GemInstaller::EmbeddedGemServer.start
  end

  # specify "should be able to install, uninstall, and check for existence of specific versions of a gem" do
  #   @gem_command_manager.install_gem(@sample_gem_with_extra_install_options)
  # 
  #   @gem_command_manager.is_gem_installed(@sample_gem).should==(true)
  #   @gem_command_manager.is_gem_installed(@nonexistent_version_sample_gem).should==(false)
  # 
  #   # uninstall it again after we are done
  #   @gem_command_manager.uninstall_gem(@sample_gem)
  #   @gem_command_manager.is_gem_installed(@sample_gem).should==(false)
  # end
  # 
  # specify "should be able to list remote gems" do
  #   list_options = ["--source=#{embedded_gem_server_url}"]
  #   @sample_gem.name = 'stubgem-multiplatform'
  #   list = @gem_command_manager.list_remote_gem(@sample_gem,list_options)
  #   expected_list = ["",
  #     "*** REMOTE GEMS ***", 
  #     "", 
  #     "stubgem-multiplatform (1.0.1, 1.0.0)", 
  #     "    Multiplatform stub gem for testing geminstaller"]
  #   list.should==(expected_list)
  # end
  
  specify "should raise an error if attempting to install a gem with dependencies without -y option" do
    # ensure dependency gem is uninstalled
    @gem_command_manager.uninstall_gem(@sample_gem)
    sample_dependent_gem = @sample_dependent_gem.dup
    sample_dependent_gem.install_options = install_options_for_testing.dup
    begin
      @gem_command_manager.install_gem(sample_dependent_gem)
      raise Spec::Expectations::ExpectationNotMetError.new("Expected to receive a GemInstaller::UnexpectedPromptError")
    rescue GemInstaller::UnexpectedPromptError => error
      expected_error_message = /RubyGems is prompting to install a required dependency.*Gem command was:.*install dependent-stubgem.*Gem command output was:.*Install required dependency stubgem/m
      error.message.should_match(expected_error_message)
    end
  end
  
  # specify "should be able to install and uninstall similarly named gems without a prompt (using exact name matching)" do
  #   gems = [@sample_gem, @sample_multiplatform_gem]
  #   gems.each do |gem|
  #     @gem_command_manager.install_gem(gem)
  #     @gem_command_manager.is_gem_installed(gem).should==(true)
  #   end
  # 
  #   # uninstall it again after we are done
  #   gems.each do |gem|
  #     @gem_command_manager.uninstall_gem(gem)
  #     @gem_command_manager.is_gem_installed(gem).should==(false)
  #   end
  # end
  # 
  # specify "should be able to install two gems with the same version but different platforms" do
  #   @sample_multiplatform_gem_for_another_platform = sample_multiplatform_gem
  #   @sample_multiplatform_gem_for_another_platform.platform = 'ruby'
  #   @gem_command_manager.uninstall_gem(@sample_multiplatform_gem_for_another_platform)
  #   gems = [@sample_multiplatform_gem, @sample_multiplatform_gem_for_another_platform]
  #   gems.each do |gem|
  #     @gem_command_manager.install_gem(gem)
  #     @gem_command_manager.is_gem_installed(gem).should==(true)
  #   end
  # 
  #   # uninstall it again after we are done
  #   gems.each do |gem|
  #     @gem_command_manager.uninstall_gem(gem)
  #     @gem_command_manager.is_gem_installed(gem).should==(false)
  #   end
  # end
  # 
  # specify "should be able to install and uninstall a gem with the 'current' platform" do
  #   gem = @sample_gem
  #   gem.platform = 'current'
  #   @gem_command_manager.is_gem_installed(gem).should==(false)
  #   @gem_command_manager.install_gem(gem)
  #   @gem_command_manager.is_gem_installed(gem).should==(true)
  # 
  #   # uninstall it again after we are done
  #   @gem_command_manager.uninstall_gem(gem)
  #   @gem_command_manager.is_gem_installed(gem).should==(false)
  # end
  
  teardown do
    sample_dependent_gem = @sample_dependent_gem.dup
    sample_dependent_gem.install_options << '-i'
    @gem_command_manager.uninstall_gem(sample_dependent_gem)
    @gem_command_manager.uninstall_gem(@sample_gem)
  end
  
end
