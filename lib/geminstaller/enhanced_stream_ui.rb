module GemInstaller
  class EnhancedStreamUI < Gem::StreamUI
    attr_writer :gem_interaction_handler, :outs, :errs
    
    def initialize()
      @ins = InputQueue.new
    end
    
    def ask_yes_no(question, default=nil)
      begin
        @gem_interaction_handler.handle_ask_yes_no(question)
      rescue Exception => e
        @outs.print(question)
        @outs.flush
        raise e
      end
      super
    end
    
    def choose_from_list(question, list)
      @gem_interaction_handler.handle_choose_from_list(question, list)
    end

    def queue_input(input)
      @ins.queue_input(input)
    end

    def terminate_interaction!(status=-1)
      raise_error(status)
    end
    
    def terminate_interaction(status=0)
      raise_error(status) unless status == 0
      raise GemInstaller::RubyGemsExit.new(status)
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

  end

  class InputQueue
    def initialize
      @queue = []
    end
    
    def queue_input(input)
      input = [input] unless input.is_a?(Array)
      @queue += input
    end
    
    def gets
      input = @queue.shift
      raise GemInstaller::UnexpectedPromptError.new("GemInstaller Internal Error: Unexpected prompt received from RubyGems- no input queued for EnhancedStreamUI.") if input.nil?
      input
    end
  end
end