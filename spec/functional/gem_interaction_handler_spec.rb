dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemInteractionHandler instance with a non-multiplatform dependent gem" do
  include GemInstaller::SpecUtils
  setup do
    @registry = GemInstaller::create_registry
    @gem_interaction_handler = @registry.gem_interaction_handler
    @dependent_gem = sample_dependent_gem
    @dependency_gem = sample_gem
  end

  specify "should raise UnauthorizedDependencyPromptError from handle_ask_yes_no if question is a dependency prompt" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    question = GemInstaller::GemInteractionHandler::DEPENDENCY_PROMPT
    begin
      @gem_interaction_handler.handle_ask_yes_no(question)
    rescue GemInstaller::UnauthorizedDependencyPromptError => error
      expected_error_message = /RubyGems is prompting to install a required dependency/m
      error.message.should_match(expected_error_message)
    end
  end

  specify "should call noninteractive_chooser for dependent gem if handle_choose_from_list is passed a list for the dependent gem" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    question = "Select which gem to install for your platform (i686-darwin8.7.1)"
    list = ["#{@dependent_gem.name} #{@dependent_gem.version} (#{@dependent_gem.platform})"]
    item, index = @gem_interaction_handler.handle_choose_from_list(question, list)
    item.should==(list[0])
    index.should==(0)
  end

  specify "should call noninteractive_chooser with nil name/version if handle_choose_from_list is passed a list for a non-dependent gem" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    question = "Select which gem to install for your platform (i686-darwin8.7.1)"
    list = ["#{@dependency_gem.name} #{@dependency_gem.version} (#{@dependency_gem.platform})"]
    item, index = @gem_interaction_handler.handle_choose_from_list(question, list)
    item.should==(list[0])
    index.should==(0)
  end
end

