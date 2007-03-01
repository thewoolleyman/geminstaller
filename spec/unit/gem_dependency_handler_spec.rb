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
    lambda{ @gem_dependency_handler.handle_prompt(question) }.should_raise(GemInstaller::UnauthorizedDependencyPromptError)
  end

end

