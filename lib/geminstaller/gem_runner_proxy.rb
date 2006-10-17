module GemInstaller
  class GemRunnerProxy
    def gem_runner=(gem_runner)
      @gem_runner = gem_runner
    end

    def run(args)
      @gem_runner.run(args)
    end
  end
end





