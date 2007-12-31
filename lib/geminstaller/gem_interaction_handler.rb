module GemInstaller
  class GemInteractionHandler
    attr_writer :dependent_gem, :noninteractive_chooser_class, :valid_platform_selector
    DEPENDENCY_PROMPT = 'Install required dependency'
    
    def handle_ask_yes_no(question)
      if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
        # gem_interaction_handler is not used for RubyGems >= 0.9.5
        raise RuntimeError.new("Internal GemInstaller Error: GemInteractionHandler should not be used for RubyGems >= 0.9.5")
      end
      return unless question.index(DEPENDENCY_PROMPT)
      message = "Error: RubyGems is prompting to install a required dependency, and you have not " +
                "specified the '--install-dependencies' option for the current gem.  You must modify your " +
                "geminstaller config file to either specify the '--install-depencencies' (-y) " +
                "option, or explicitly add an entry for the dependency gem earlier in the file.\n"
      raise GemInstaller::UnauthorizedDependencyPromptError.new(message)
    end
    
    def handle_choose_from_list(question, list, noninteractive_chooser = nil)
      if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
        # gem_interaction_handler is not used for RubyGems >= 0.9.5
        raise RuntimeError.new("Internal GemInstaller Error: GemInteractionHandler should not be used for RubyGems >= 0.9.5")
      end
      noninteractive_chooser ||= @noninteractive_chooser_class.new
      valid_platforms = nil
      if dependent_gem_with_platform_specified?(list, noninteractive_chooser) or noninteractive_chooser.uninstall_list_type?(question)
        valid_platforms = [@dependent_gem.platform]
      else
        valid_platforms = @valid_platform_selector.select(@dependent_gem.platform)
      end
      noninteractive_chooser.choose(question, list, @dependent_gem.name, @dependent_gem.version, valid_platforms)
    end
    
    def dependent_gem_with_platform_specified?(list, noninteractive_chooser)
      noninteractive_chooser.dependent_gem?(@dependent_gem.name, list) and @dependent_gem.platform
    end
  end
end
