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
        return choose_gem(@parent_gem.name,@parent_gem.version,@parent_gem.platform, question, list)
      end
      # choose the first gem with a platform matching the parent gem
      return choose_gem(nil,nil,@parent_gem.platform, question, list)
    end
    
    def choose_gem(name, version, platform, question, list)
      @noninteractive_chooser.specify_gem_spec(name, version, platform)
      @noninteractive_chooser.choose(question, list)
    end
  end
end
