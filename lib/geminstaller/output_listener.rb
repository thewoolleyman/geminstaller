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
    
    def notify(msg, stream = :stdout)
      @messages.push(msg)
      return unless @output_proxy
      return unless @echo
      if stream == :stdout
        @output_proxy.sysout(msg)
      elsif stream == :stderr
        @output_proxy.syserr(msg)
      else
        raise GemInstaller::GemInstallerError.new("Invalid stream specified: #{@stream}")
      end
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