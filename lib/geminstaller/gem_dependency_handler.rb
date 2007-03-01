module GemInstaller
  class GemDependencyHandler
    attr_writer :parent_gem
    DEPENDENCY_PROMPT = 'Install required dependency'
    
    def handle_prompt(question)
      return unless question.index(DEPENDENCY_PROMPT)
      message = "Error: RubyGems is prompting to install a required dependency, and you have not " +
                "specified the '--install-dependencies' option for the current gem.  You must modify your " +
                "geminstaller config file to either specify the '--install-depencencies' (-y) " +
                "option, or explicitly add an entry for the dependency gem earlier in the file.\n"
      raise GemInstaller::UnauthorizedDependencyPromptError.new(message)
    end
  end
end
