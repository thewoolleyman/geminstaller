dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a GemListChecker instance with mock dependencies" do
  before(:each) do
    @mock_gem_command_manager = mock("Mock GemCommandManager")
    @mock_gem_arg_processor = mock("Mock GemArgProcessor")
    @gem_list_checker = GemInstaller::GemListChecker.new
    @gem_list_checker.gem_command_manager = @mock_gem_command_manager
    @gem_list_checker.gem_arg_processor = @mock_gem_arg_processor
    @sample_gem = sample_gem
  end

  it "should raise exception for unexpected case of multiple matches in list" do
    @mock_gem_arg_processor.should_receive(:strip_non_common_gem_args)
    stub_remote_list = ['stubgem (1.0.0)', 'stubgem (unexpected_version)']
    @mock_gem_command_manager.should_receive(:list_remote_gem).and_return(stub_remote_list)
    
    lambda{ @gem_list_checker.find_remote_matching_gem(@sample_gem) }.should raise_error(GemInstaller::GemInstallerError)
  end
end

