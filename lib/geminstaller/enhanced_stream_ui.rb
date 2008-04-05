module GemInstaller
  class EnhancedStreamUI < Gem::StreamUI
    attr_writer :outs, :errs
    attr_writer :gem_interaction_handler if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
    
    def initialize()
      # override default constructor to have no args
    end
    
    def ask_yes_no(question, default=nil)
      if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
        # Using defaults, we expect no interactive prompts RubyGems >= 0.9.5
        begin
          @gem_interaction_handler.handle_ask_yes_no(question)
        rescue Exception => e
          @outs.print(question)
          @outs.flush
          raise e
        end
      end
      raise_unexpected_prompt_error(question)
    end
    
    def ask(question)
      raise_unexpected_prompt_error(question)
    end
    
    def choose_from_list(question, list)
      if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.4')
        # Using defaults, we expect no interactive prompts RubyGems >= 0.9.5
        @gem_interaction_handler.handle_choose_from_list(question, list)
      else
        list_string = list.join("\n")
        question_and_list = "#{question}\n#{list_string}"
        raise_unexpected_prompt_error(question_and_list)
      end
    end

    if GemInstaller::RubyGemsVersionChecker.matches?('<=1.0.1')
    # explicit exit in terminate_interation was removed after 1.0.1
    def terminate_interaction!(status=-1)
      raise_error(status)
    end
    
    def terminate_interaction(status=0)
      raise_error(status) unless status == 0
      raise GemInstaller::RubyGemsExit.new(status)
    end
    end
    
    def alert_error(statement, question=nil)
      # if alert_error got called due to a GemInstaller::UnexpectedPromptError, re-throw it
      last_exception = $!
      if last_exception.class == GemInstaller::UnauthorizedDependencyPromptError || last_exception.class == GemInstaller::RubyGemsExit
        raise last_exception
      end
      # otherwise let alert_error continue normally...
      super(statement, question)
    end
    
    protected
    def raise_error(status)
      raise GemInstaller::GemInstallerError.new("RubyGems exited abnormally.  Status: #{status}\n")
    end
    
    def raise_unexpected_prompt_error(question)
      raise GemInstaller::UnexpectedPromptError.new("GemInstaller Internal Error - Unexpected prompt received from RubyGems: '#{question}'.")
    end

  end
end