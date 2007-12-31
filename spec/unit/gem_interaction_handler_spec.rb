dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
# gem_interaction_handler is not used for RubyGems >= 0.9.5
describe "a GemInteractionHandler instance with mock dependencies" do
  before(:each) do
    @gem_interaction_handler = GemInstaller::GemInteractionHandler.new
    @dependent_gem = sample_dependent_gem
    @gem_interaction_handler.dependent_gem = @dependent_gem
    @mock_noninteractive_chooser = mock("Mock NoninteractiveChooser")
  end

  it "should pass only the specified platform when given a list for a dependent gem which has a platform specified" do
    question = "question"
    list = ["item"]
    @mock_noninteractive_chooser.should_receive(:dependent_gem?).with(@dependent_gem.name, list).and_return(true)
    @mock_noninteractive_chooser.should_receive(:choose).with(
      question, list, @dependent_gem.name, @dependent_gem.version, [@dependent_gem.platform])
    @gem_interaction_handler.handle_choose_from_list(question, list, @mock_noninteractive_chooser)
  end

  it "should call valid_platform_selector when given a list for a gem which is not the dependent gem" do
    question = "question"
    list = ["item", "item"]
    valid_platform_list = ["valid-platform-1", "valid-platform-2"]
    @mock_valid_platform_selector = mock("Mock ValidPlatformSelector")
    @mock_valid_platform_selector.should_receive(:select).with(@dependent_gem.platform).and_return(valid_platform_list)
    @gem_interaction_handler.valid_platform_selector = @mock_valid_platform_selector
    @mock_noninteractive_chooser.should_receive(:dependent_gem?).with(@dependent_gem.name, list).and_return(false)
    @mock_noninteractive_chooser.should_receive(:uninstall_list_type?).with(question).and_return(false)
    @mock_noninteractive_chooser.should_receive(:choose).with(
      question, list, @dependent_gem.name, @dependent_gem.version, valid_platform_list)
    @gem_interaction_handler.handle_choose_from_list(question, list, @mock_noninteractive_chooser)
  end
end
end