dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an InstallProcessor instance with no options passed" do
  setup do
    install_processor_spec_setup_common
    @sample_gem.fix_dependencies = false
  end

  specify "should install a gem" do
    @mock_gem_command_manager.should_receive(:is_gem_installed?).once.with(@sample_gem).and_return(false)
    @mock_gem_list_checker.should_receive(:verify_and_specify_remote_gem!).once.with(@sample_gem)
    @mock_gem_command_manager.should_receive(:install_gem).once.with(@sample_gem).and_return([])
    @install_processor.process([@sample_gem])
  end  
end

context "an InstallProcessor instance invoked with info, quiet options passed" do
  setup do
    install_processor_spec_setup_common
    @sample_gem.fix_dependencies = false
    @options[:info] = true
    @options[:quiet] = true
  end

  specify "should show info message for a gem which is already installed" do
    @sample_gem.check_for_upgrade = false
    @mock_gem_command_manager.should_receive(:is_gem_installed?).once.with(@sample_gem).and_return(true)
    @mock_output_proxy.should_receive(:sysout).once().with(/Gem .*, version .*is already installed/)
    @install_processor.process([@sample_gem])
  end
end

context "an InstallProcessor instance invoked with quiet option" do
  setup do
    install_processor_spec_setup_common
    @sample_gem.fix_dependencies = false
    @options[:quiet] = true
  end

  specify "should not install a gem which is already installed and not print installed message" do
    @sample_gem.check_for_upgrade = false
    @mock_gem_command_manager.should_receive(:is_gem_installed?).once.with(@sample_gem).and_return(true)
    @install_processor.process([@sample_gem])
  end

  specify "should verify and specify gem if check_for_upgrade is specified" do
    @sample_gem.check_for_upgrade = true
    @mock_gem_list_checker.should_receive(:verify_and_specify_remote_gem!).once.with(@sample_gem)
    @mock_gem_command_manager.should_receive(:is_gem_installed?).once.with(@sample_gem).and_return(true)
    @install_processor.process([@sample_gem])
  end
end


def install_processor_spec_setup_common
  @install_processor = GemInstaller::InstallProcessor.new

  @mock_gem_command_manager = mock("Mock GemCommandManager")
  @mock_output_proxy = mock("Mock Output Proxy")
  @mock_gem_list_checker = mock("Mock GemListChecker")
  @mock_missing_dependency_finder = mock("Mock MissingDependencyFinder")
  @options = {}

  @install_processor.gem_list_checker = @mock_gem_list_checker
  @install_processor.gem_command_manager = @mock_gem_command_manager
  @install_processor.options = @options
  @install_processor.output_proxy = @mock_output_proxy
  @install_processor.missing_dependency_finder = @mock_missing_dependency_finder

  @sample_gem = sample_gem
end
