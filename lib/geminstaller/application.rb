require 'yaml'

module GemInstaller
  class Application
    attr_writer :config
    def run
      puts :config.inspect
    end
  end
end