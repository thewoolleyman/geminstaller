dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemInteractionHandler instance with a non-multiplatform dependent gem and non-multiplatform dependency gem" do
  include GemInstaller::SpecUtils
  setup do
    gem_interaction_handler_spec_setup_common(sample_dependent_gem, sample_gem)    
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

  specify "should call noninteractive_chooser for dependent gem if handle_choose_from_list is passed an install-formatted list for the dependent gem" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    list = ["#{@dependent_gem.name} #{@dependent_gem.version} (#{@dependent_gem.platform})"]
    should_choose_properly(list, 0)
  end

  specify "should choose properly if handle_choose_from_list is passed an install-formatted list for a non-dependent gem" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    list = ["#{@dependency_gem.name} #{@dependency_gem.version} (#{@dependency_gem.platform})"]
    should_choose_properly(list, 0)
  end
end

context "a GemInteractionHandler instance with a multiplatform dependent gem and non-multiplatform child gem" do
  include GemInstaller::SpecUtils
  setup do
    gem_interaction_handler_spec_setup_common(sample_dependent_multiplatform_gem, sample_gem)    
  end

  specify "should choose properly if handle_choose_from_list is passed a list for a non-dependent gem" do
    # TODO: fix this - should make noninteractive_chooser take an array of possible valid platforms
    #    should_choose_properly
  end
end

context "a GemInteractionHandler instance with a non-multiplatform dependent gem and multiplatform child gem" do
  include GemInstaller::SpecUtils
  setup do
    gem_interaction_handler_spec_setup_common(sample_dependent_gem, sample_multiplatform_gem)    
  end

  specify "should choose properly if handle_choose_from_list is passed a list for a non-dependent gem" do
    # TODO: fix this - should make noninteractive_chooser take an array of possible valid platforms
    #should_choose_properly
  end
end

def should_choose_properly(list, expected_item_index)
  question = "Select which gem to install for your platform (i686-darwin8.7.1)"
  item, index = @gem_interaction_handler.handle_choose_from_list(question, list)
  item.should==(list[expected_item_index])
  index.should==(expected_item_index)
end

def gem_interaction_handler_spec_setup_common(dependent_gem, dependency_gem)
  @registry = GemInstaller::create_registry
  @gem_interaction_handler = @registry.gem_interaction_handler
  @dependent_gem = dependent_gem
  @dependency_gem = dependency_gem
end