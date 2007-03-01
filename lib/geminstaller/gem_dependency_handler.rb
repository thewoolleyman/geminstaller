module GemInstaller
  class GemDependencyHandler
    attr_writer :parent_gem
    DEPENDENCY_PROMPT = 'Install required dependency'
    
    def handle_prompt(question)
      return unless question.index('Install required dependency')
      raise GemInstaller::UnauthorizedDependencyPromptError.new()
    end
  end
end
