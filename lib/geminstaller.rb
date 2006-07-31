require 'geminstaller/main_loop'

module GemInstaller

  class << self
    def application
      @application ||= GemInstaller::Application.new
    end
  end

  ######################################################################
  # GemInstaller main application object.  When invoking +geminstaller+ from the
  # command line, a GemInstaller::Application object is created and run.
  #
  class Application
    # Run the +geminstaller+ application.
    def run
      container = Container.new
      container.start
    end
  end
end