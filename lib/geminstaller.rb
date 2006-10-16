require 'geminstaller/dependency_injector'

module GemInstaller

  class << self
    def runner
      @application ||= GemInstaller::Runner.new
    end
  end

  ######################################################################
  # GemInstaller entry point.  When invoking +geminstaller+ from the
  # command line, a GemInstaller::Runner object is created and run.
  #
  class Runner
    # Run the +geminstaller+ application.
    def run
      application = GemInstaller::DependencyInjector.new.registry.app
      application.run
    end
  end
end