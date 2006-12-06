dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/geminstaller/requires.rb")

module GemInstaller

  def self.runner
    GemInstaller::Runner.new
  end
  
  def self.run
    runner.run
  end
  
  def self.version
    "0.0.1"
  end

  class Runner
    def run
      application = create_registry.app
      application.run
    end
    
    def create_registry
      GemInstaller::DependencyInjector.new.registry
    end
  end
end