module GemInstaller
  class GemRunnerProxy
    attr_writer :gem_runner

    def run(args)
      @gem_runner.run(args)
      sleep 3
    end
  end
end





