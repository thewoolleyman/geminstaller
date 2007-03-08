module GemInstaller
  class GemInteractionHandler
    attr_writer :dependent_gem, :noninteractive_chooser
    DEPENDENCY_PROMPT = 'Install required dependency'
    
    def handle_ask_yes_no(question)
      return unless question.index(DEPENDENCY_PROMPT)
      message = "Error: RubyGems is prompting to install a required dependency, and you have not " +
                "specified the '--install-dependencies' option for the current gem.  You must modify your " +
                "geminstaller config file to either specify the '--install-depencencies' (-y) " +
                "option, or explicitly add an entry for the dependency gem earlier in the file.\n"
      raise GemInstaller::UnauthorizedDependencyPromptError.new(message)
    end
    
    def handle_choose_from_list(question, list)
      @noninteractive_chooser.specify_gem_spec(@dependent_gem.name,@dependent_gem.version,@dependent_gem.platform)
      @noninteractive_chooser.choose(question, list)
    end
  end
end
