module GemInstaller
  class OutputProxy
    attr_writer :options
    def default_stream=(stream)
      raise GemInstaller::GemInstallerError.new("Invalid default stream: #{stream}") unless stream == :stderr or stream == :stdout
      @default_stream = stream
    end

    def sysout(out)
      return if silent?
      $stdout.print out
    end

    def syserr(err)
      return if silent?
      if @options[:redirect_stderr_to_stdout]
        $stdout.print err
      else
        $stderr.print err
      end
    end
    
    # TODO: should remove this, make callers explicitly choose.
    def output(output)
      if @default_stream == :stdout
        sysout(output)
      else
        syserr(output)
      end
    end
    
    def silent?
      @options && @options[:silent]
    end
  end
end