dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemDependencyHandler instance" do
  include GemInstaller::SpecUtils
  setup do
    @gem_dependency_handler = GemInstaller::GemDependencyHandler.new
    @mock_noninteractive_chooser = mock("Mock NonInteractiveChooser")
    @gem_dependency_handler.noninteractive_chooser = @mock_noninteractive_chooser
    @parent_gem = sample_dependent_gem
  end

  specify "should raise UnauthorizedDependencyPromptError from handle_prompt if question is a dependency prompt" do
    @gem_dependency_handler.parent_gem = @parent_gem
    question = GemInstaller::GemDependencyHandler::DEPENDENCY_PROMPT
    begin
      @gem_dependency_handler.handle_prompt(question)
    rescue GemInstaller::UnauthorizedDependencyPromptError => error
      expected_error_message = /RubyGems is prompting to install a required dependency/m
      error.message.should_match(expected_error_message)
    end
  end

  specify "should call noninteractive_chooser for parent gem if handle_choose_from_list is passed a list for the parent gem" do
    @gem_dependency_handler.parent_gem = @parent_gem
    question = "Select which gem to install for your platform (i686-darwin8.7.1)"
    list = ["#{@parent_gem.name} #{@parent_gem.version} (#{@parent_gem.platform})"]
    @mock_noninteractive_chooser.should_receive(:specify_exact_gem_spec).with(@parent_gem.name, @parent_gem.version, @parent_gem.platform)
    @mock_noninteractive_chooser.should_receive(:choose).with(question, list).and_return([list[0],0])
    item, index = @gem_dependency_handler.handle_choose_from_list(question, list)
    item.should==(list[0])
    index.should==(0)
  end
end

