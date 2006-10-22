module GemInstaller
  class OutputProxy
    def sysout(out)
      $stdout.print out
    end

    def syserr(err)
      $stderr.print err
    end
  end
end