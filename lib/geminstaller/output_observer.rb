module GemInstaller
  class OutputObserver
    attr_writer :stream
    # TODO: GemRunnerProxy should raise exception if listener still has any leftover output when run is invoked. 
    def initialize
      @stream = :stdout
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
        listener.notify(output, @stream)
      end
    end
    
    def puts(output)
      print("#{output}\n")
    end
    
    def flush
    end
  end
end