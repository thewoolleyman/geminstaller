module GemInstaller
  class OutputProxy
    def default_stream=(stream)
      raise GemInstaller::GemInstallerError.new("Invalid default stream: #{stream}") unless stream == :stderr or stream == :stdout
      @default_stream = stream
    end

    def sysout(out)
      $stdout.print out
    end

    def syserr(err)
      $stderr.print err
    end
    
    # TODO: should remove this, make callers explicitly choose.
    def output(output)
      if @default_stream == :stdout
        sysout(output)
      else
        syserr(output)
      end
    end
  end
end