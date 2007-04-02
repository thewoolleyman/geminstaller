dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/requires.rb")

module GemInstaller
  class OutputListener
    attr_writer :output_filter
    
    def initialize
      @messages = []
      @output_filter = nil
    end
    
    def notify(msg, stream = :stdout)
      @messages.push(msg)
      return unless @output_filter
      if stream == :stdout or stream == :stderr
        @output_filter.rubygems_output(stream, msg)
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