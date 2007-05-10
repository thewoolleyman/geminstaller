dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemInteractionHandler instance with a non-multiplatform dependent gem and non-multiplatform dependency gem" do
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
      error.message.should match(expected_error_message)
    end
  end

  specify "should call noninteractive_chooser for dependent gem if handle_choose_from_list is passed an install-formatted list for the dependent gem" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    list = ["#{@dependent_gem.name} #{@dependent_gem.version} (#{@dependent_gem.platform})"]
    list << 'Cancel'
    should_choose_properly(list, 0)
  end

  specify "should choose properly if handle_choose_from_list is passed an install-formatted list for a non-dependent gem" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    list = ["#{@dependency_gem.name} #{@dependency_gem.version} (#{@dependency_gem.platform})"]
    should_choose_properly(list, 0)
  end
end

context "a GemInteractionHandler instance with a non-multiplatform dependency gem and multiplatform dependent gem" do
  setup do
    gem_interaction_handler_spec_setup_common(sample_dependent_depends_on_multiplatform_gem, sample_dependent_multiplatform_gem)    
    @valid_platform_selector = @registry.valid_platform_selector
    @valid_platform_selector.ruby_platform = "i386-mswin32"
  end

  specify "should choose multiplatform dependency gem before ruby platform" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    list = ["#{@dependency_gem.name} #{@dependency_gem.version} (#{GemInstaller::RubyGem.default_platform})"]
    list << "#{@dependency_gem.name} #{@dependency_gem.version} (#{@dependency_gem.platform})"
    list << 'Cancel'
    should_choose_properly(list, 1)
  end

  specify "should choose ruby platform if no matching valid binary platform is found" do
    @gem_interaction_handler.dependent_gem = @dependent_gem
    list = ["#{@dependency_gem.name} #{@dependency_gem.version} (nonmatching-binary-platform)"]
    list << "#{@dependency_gem.name} #{@dependency_gem.version} (#{GemInstaller::RubyGem.default_platform})"
    list << 'Cancel'
    should_choose_properly(list, 1)
  end

  specify "should choose dependent gem platform if it is specified and the list is for the dependent gem, even if other matches exist" do
    @dependent_gem.platform = "mswin32"
    @gem_interaction_handler.dependent_gem = @dependent_gem
    list = ["#{@dependent_gem.name} #{@dependent_gem.version} (#{GemInstaller::RubyGem.default_platform})"]
    list << "#{@dependent_gem.name} #{@dependent_gem.version} (i386-mswin32)"
    list << "#{@dependent_gem.name} #{@dependent_gem.version} (#{@dependent_gem.platform})"
    list << 'Cancel'
    should_choose_properly(list, 2)
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