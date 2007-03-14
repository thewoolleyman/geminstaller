dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/requires.rb")

module GemInstaller
  class OutputListener
    attr_writer :echo, :output_proxy
    
    def initialize
      @messages = []
      @echo = true
      @output_proxy = nil
    end
    
    def notify(msg)
      @messages.push(msg)
      @output_proxy.output(msg) if !@output_proxy.nil? and @echo
    end
    
    def read
      @messages.dup
    end

    def read!
      messages = @messages.dup
      @messages.clear
      messages
    end
  end
end