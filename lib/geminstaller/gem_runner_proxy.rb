module GemInstaller
  class GemRunnerProxy
    attr_writer :gem_runner_class

    def run(args)
      gem_runner = @gem_runner_class.new
      gem_runner.run(args)
    end
  end
end





