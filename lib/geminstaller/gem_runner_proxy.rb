module GemInstaller
  class GemRunnerProxy
    attr_writer :gem_runner

    def run(args)
      @gem_runner.run(args)
    end
  end
end





