module GemInstaller
  class GemInteractionHandler
    attr_writer :parent_gem, :noninteractive_chooser
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
      if list[0] =~ /^#{@parent_gem.name}.*/
        setup_noninteractive_chooser(@parent_gem.name,@parent_gem.version,@parent_gem.platform)
        return @noninteractive_chooser.choose(question, list)
      end
      raise RuntimeError.new("Fell through in GemInteractionHandler - FIXME")
    end
    
    def setup_noninteractive_chooser(name, version, platform)
      @noninteractive_chooser.specify_exact_gem_spec(name, version, platform)
    end
  end
end
