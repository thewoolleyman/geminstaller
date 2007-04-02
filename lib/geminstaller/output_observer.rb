module GemInstaller
  class OutputObserver
    # TODO: 
    # Extract this to it's own file
    # add a property for stream - :stdin/:stdout
    # move OutputListener creation from GemRunnerProxy to be injected instead
    # inject only a singleton instance of GemRunnerProxy
    # call notify on listener with :stdin/:stdout param
    # inject the singleton listener into GemRunnerProxy
    # GemRunnerProxy should raise exception if listener still has any leftover output when run is invoked. 
    def initialize
      @listeners = []
    end

    def register(listener)
      listener = [listener] unless listener.is_a?(Array)
      @listeners += listener
    end
    
    def unregister(listener)
      @listeners.delete(listener)
    end
    
    def print(output)
      @listeners.each do |listener|
        listener.notify(output)
      end
    end
    alias puts print
    
    def flush
    end
  end
end