dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemDependencyHandler instance" do
  include GemInstaller::SpecUtils
  setup do
    @gem_dependency_handler = GemInstaller::GemDependencyHandler.new
    @parent_gem = sample_dependent_gem
  end

  specify "will raise UnauthorizedDependencyPromptError if question is a dependency prompt and
           parent gem does not have --install-dependences specified" do
    @gem_dependency_handler.parent_gem = @parent_gem
    question = GemInstaller::GemDependencyHandler::DEPENDENCY_PROMPT
    begin
      @gem_dependency_handler.handle_prompt(question)
    rescue GemInstaller::UnauthorizedDependencyPromptError => error
      expected_error_message = /RubyGems is prompting to install a required dependency/m
      error.message.should_match(expected_error_message)
    end
    
  end

end

