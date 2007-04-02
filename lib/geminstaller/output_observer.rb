module GemInstaller
  class OutputObserver
    attr_writer :stream
    # TODO: 
    # DONE Extract this to it's own file
    # DONE: add a property for stream - :stdin/:stdout
    # DONE: move OutputListener creation from GemRunnerProxy to be injected instead
    # DONE: inject only a singleton instance of OutputListener
    # DONE: inject output observer for both streams into enhanced_stream_ui, instead of creating them
    # DONE: call notify on listener with :stdin/:stdout param
    # DONE: inject the singleton listener into GemRunnerProxy
    #  GemRunnerProxy should raise exception if listener still has any leftover output when run is invoked. 
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